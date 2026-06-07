import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute, RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ItemsClient, ItemListDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { ToastService } from '../../../shared/services/toast.service';
import { MatDialog } from '@angular/material/dialog';
import { AuthService } from '../../../core/services/auth.service';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

@Component({
  selector: 'app-items-list',
  standalone: true,
  imports: [
    CommonModule,
    TranslateModule,
    MatTableModule,
    MatSortModule,
    MatIconModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatButtonModule,
    MatPaginatorModule,
    MatButtonToggleModule,
    HeaderSectionComponent,
    LoadingButtonComponent,
    RouterModule
  ],
  templateUrl: './items-list.component.html',
  styleUrl: './items-list.component.scss',
})
export class ItemsListComponent implements OnInit {
  private apiClient = inject(ItemsClient);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);
  private authService = inject(AuthService);
  private http = inject(HttpClient);

  isOwnerMode = signal(false);

  isOwner(item: ItemListDto): boolean {
    const currentUserId = this.authService.getCurrentUserId();
    return currentUserId !== null && item.ownerId === currentUserId;
  }

  displayedColumns = ['image', 'title', 'price', 'category', 'actions'];
  dataSource = signal<ItemListDto[]>([]);
  isLoading = signal(false);
  viewMode = signal<'list' | 'cards'>('cards');

  // Pagination & Filtering state
  searchTerm = signal('');
  pageNumber = signal(1);
  pageSize = signal(10);
  totalCount = signal(0);

  // Sorting state
  sortBy = signal<string | null>('newest');
  sortOrder = signal<'asc' | 'desc' | null>('desc');

  constructor() {
    effect(
      () => {
        const mode = this.viewMode();
        untracked(() => {
          this.pageNumber.set(1);
          this.pageSize.set(mode === 'cards' ? 12 : 10);
        });
      },
    );

    effect(
      () => {
        this.getData();
      },
    );
  }

  ngOnInit() {
    // Read mode from route data
    this.route.data.subscribe((data: any) => {
      if (data['ownerMode'] === 'me') {
        this.isOwnerMode.set(true);
      }
    });
  }

  private getData() {
    this.isLoading.set(true);
    const term = this.searchTerm().trim().toLowerCase();

    this.apiClient
      .getItems(
        this.pageNumber(),
        this.pageSize(),
        undefined, // categoryId
        undefined, // subcategoryId
        undefined, // city
        undefined, // minPrice
        undefined, // maxPrice
        undefined, // startDate
        undefined, // endDate
        undefined, // minRating
        undefined, // type
        undefined, // condition
        this.sortBy() ?? undefined,
        this.sortOrder() ?? undefined,
        this.isOwnerMode() ? 'me' : undefined, // owner
      )
      .pipe(
        tap((response: any) => {
          const items = response?.data ?? [];
          const filteredItems = term
            ? items.filter((item: ItemListDto) => {
                const titleAr = (item.titleAr ?? '').toLowerCase();
                const titleEn = (item.titleEn ?? '').toLowerCase();
                const categoryAr = (item.category?.nameAr ?? '').toLowerCase();
                const categoryEn = (item.category?.nameEn ?? '').toLowerCase();
                const subcategoryAr = (item.subcategory?.nameAr ?? '').toLowerCase();
                const subcategoryEn = (item.subcategory?.nameEn ?? '').toLowerCase();
                return (
                  titleAr.includes(term) ||
                  titleEn.includes(term) ||
                  categoryAr.includes(term) ||
                  categoryEn.includes(term) ||
                  subcategoryAr.includes(term) ||
                  subcategoryEn.includes(term)
                );
              })
            : items;

          this.dataSource.set(filteredItems);
          this.totalCount.set(term ? filteredItems.length : response?.total ?? 0);
        }),
        catchError((err: any) => {
          console.error('Failed to load items', err);
          this.dataSource.set([]);
          this.toast.showError('errors.failedToLoadProducts');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
      )
      .subscribe();
  }

  onSearchChange(event: string | Event): void {
    const value = typeof event === 'string' ? event : (event.target as HTMLInputElement).value;
    this.searchTerm.set(value);
    this.pageNumber.set(1);
  }

  onPageChange(event: PageEvent): void {
    this.pageNumber.set(event.pageIndex + 1);
    this.pageSize.set(event.pageSize);
  }

  onSort(sort: Sort): void {
    this.sortBy.set(sort.active);
    this.sortOrder.set(sort.direction ? (sort.direction as 'asc' | 'desc') : null);
    this.pageNumber.set(1);
  }

  editItem(id: string) {
    this.router.navigate(['/items', id, 'edit']);
  }

  viewItem(id: string) {
    this.router.navigate(['/items', id]);
  }

  createItem() {
    this.router.navigate(['/items/new']);
  }

  getPageTitle(): string {
    return this.isOwnerMode() ? 'nav.myItems' : 'products.title';
  }

  async deleteItem(id: string) {
    const item = this.dataSource().find((x: ItemListDto) => x.id === id);
    const isRemoved = item?.status === 'Removed';
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: this.translate.instant('buttons.delete'),
        message: this.translate.instant(
          isRemoved ? 'products.permanentDeleteConfirmation' : 'products.deactivateConfirmation'
        ),
        confirmText: this.translate.instant('buttons.delete'),
        cancelText: this.translate.instant('buttons.cancel'),
      } as ConfirmDialogData,
      width: '480px',
    });

    const confirmed = await dialogRef.afterClosed().toPromise();
    if (confirmed) {
      this.isLoading.set(true);
      this.apiClient
        .deleteItem(id)
        .pipe(
          tap((res: any) => {
            if (res.error) {
              this.toast.showError(res.messages?.[0] || 'errors.unknownError');
            } else {
              this.toast.showSuccess(
                res.messages?.[0] || (isRemoved ? 'products.permanentDeleteSuccess' : 'products.deactivateSuccess')
              );
              this.getData();
            }
          }),
          catchError((err: any) => {
            console.error('Delete failed', err);
            this.toast.showError('errors.unknownError');
            return of(null);
          }),
          finalize(() => this.isLoading.set(false)),
        )
        .subscribe();
    }
  }

  reactivateItem(id: string): void {
    // kept for backward compatibility; use confirm handler
    this.reactivateItemWithConfirm(id);
  }

  async reactivateItemWithConfirm(id: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: this.translate.instant('buttons.reactivate'),
        message: this.translate.instant('products.reactivateConfirmation'),
        confirmText: this.translate.instant('buttons.reactivate'),
        cancelText: this.translate.instant('buttons.cancel'),
      } as ConfirmDialogData,
      width: '480px',
    });

    const confirmed = await dialogRef.afterClosed().toPromise();
    if (!confirmed) return;

    this.isLoading.set(true);
    this.http
      .post<any>(`${environment.apiUrl}/api/v1/items/${id}/reactivate`, {})
      .pipe(
        tap((res: any) => {
          if (res?.error) {
            this.toast.showError(res.messages?.[0] || 'errors.unknownError');
          } else {
            this.toast.showSuccess(res?.messages?.[0] || 'products.reactivateSuccess');
            this.getData();
          }
        }),
        catchError(() => {
          this.toast.showError('errors.unknownError');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false))
      )
      .subscribe();
  }

  isRemoved(item: ItemListDto): boolean {
    return item.status === 'Removed';
  }

  getLocalizedTitle(item: ItemListDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? item.titleAr || item.titleEn || '' : item.titleEn || item.titleAr || '';
  }

  getLocalizedName(ref: { nameAr?: string; nameEn?: string } | undefined | null): string {
    if (!ref) return '';
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? ref.nameAr || ref.nameEn || '' : ref.nameEn || ref.nameAr || '';
  }
}
