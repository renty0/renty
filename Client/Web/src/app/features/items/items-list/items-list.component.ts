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

  isOwnerMode = signal(false);

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
      { allowSignalWrites: true },
    );

    effect(
      () => {
        this.getData();
      },
      { allowSignalWrites: true },
    );
  }

  ngOnInit() {
    // Read mode from route data
    this.route.data.subscribe((data) => {
      if (data['ownerMode'] === 'me') {
        this.isOwnerMode.set(true);
      }
    });
  }

  private getData() {
    this.isLoading.set(true);

    this.apiClient
      .getItems(
        this.pageNumber(),
        this.pageSize(),
        undefined, // categoryId
        undefined, // subcategoryId
        undefined, // city
        undefined, // minPrice
        undefined, // maxPrice
        undefined, // type
        undefined, // condition
        this.sortBy() ?? undefined,
        this.sortOrder() ?? undefined,
        this.isOwnerMode() ? 'me' : undefined, // owner
      )
      .pipe(
        tap((response) => {
          this.dataSource.set(response?.data ?? []);
          this.totalCount.set(response?.total ?? 0);
        }),
        catchError((err) => {
          console.error('Failed to load items', err);
          this.dataSource.set([]);
          this.toast.showError('errors.failedToLoadProducts');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
      )
      .subscribe();
  }

  onSearchChange(event: any): void {
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
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: this.translate.instant('buttons.delete'),
        message: this.translate.instant('products.deleteConfirmation'),
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
          tap((res) => {
            if (res.error) {
              this.toast.showError(res.messages?.[0] || 'errors.unknownError');
            } else {
              this.toast.showSuccess(res.messages?.[0] || 'products.deleteSuccess');
              this.getData();
            }
          }),
          catchError((err) => {
            console.error('Delete failed', err);
            this.toast.showError('errors.unknownError');
            return of(null);
          }),
          finalize(() => this.isLoading.set(false)),
        )
        .subscribe();
    }
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
