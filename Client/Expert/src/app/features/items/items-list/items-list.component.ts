import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatChipsModule } from '@angular/material/chips';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { 
  ItemsClient, ItemListDto, AdminItemsClient, ReviewItemCommand, 
  CategoriesClient, SubcategoriesClient, SearchClient, ProductCategoryDto, ProductSubcategoryDto 
} from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { ToastService } from '../../../shared/services/toast.service';
import { MatDialog } from '@angular/material/dialog';
import { EGYPT_GOVERNORATES } from '../../profile/profile.constants';

@Component({
  selector: 'app-items-list',
  standalone: true,
  imports: [
    CommonModule, TranslateModule, MatTableModule, MatSortModule, MatIconModule, MatCardModule,
    MatProgressSpinnerModule, MatButtonModule, MatPaginatorModule, MatButtonToggleModule,
    HeaderSectionComponent, LoadingButtonComponent, RouterModule, FormsModule, MatInputModule,
    MatSelectModule, MatExpansionModule, MatChipsModule, MatFormFieldModule, MatDatepickerModule,
    MatNativeDateModule
  ],
  templateUrl: './items-list.component.html',
  styleUrl: './items-list.component.scss',
})
export class ItemsListComponent implements OnInit {
  private apiClient = inject(ItemsClient);
  private adminClient = inject(AdminItemsClient);
  private searchClient = inject(SearchClient);
  private categoriesClient = inject(CategoriesClient);
  private subcategoriesClient = inject(SubcategoriesClient);
  private router = inject(Router);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  displayedColumns = ['image', 'title', 'price', 'category', 'actions'];
  dataSource = signal<ItemListDto[]>([]);
  isLoading = signal(false);
  isLoadingCategories = signal(false);
  isLoadingSubcategories = signal(false);
  viewMode = signal<'list' | 'cards'>('cards');

  categories = signal<ProductCategoryDto[]>([]);
  subcategories = signal<ProductSubcategoryDto[]>([]);
  governorates = EGYPT_GOVERNORATES;
  itemTypes = [
    { key: 'standard', name: 'labels.types.standard' },
    { key: 'premium', name: 'labels.types.premium' }
  ];

  searchTerm = signal('');
  selectedCategoryId = signal<number | undefined>(undefined);
  selectedSubcategoryId = signal<number | undefined>(undefined);
  selectedCity = signal<string | undefined>(undefined);
  minPrice = signal<number | undefined>(undefined);
  maxPrice = signal<number | undefined>(undefined);
  selectedType = signal<string | undefined>(undefined);
  startDate = signal<Date | undefined>(undefined);
  endDate = signal<Date | undefined>(undefined);
  minRating = signal<number | undefined>(undefined);
  sortBy = signal<string | null>('newest');
  sortOrder = signal<'asc' | 'desc' | null>('desc');

  pageNumber = signal(1);
  pageSize = signal(12);
  totalCount = signal(0);

  constructor() {
    effect(() => {
      this.selectedCategoryId();
      this.selectedSubcategoryId();
      this.searchTerm();
      this.selectedCity();
      this.minPrice();
      this.maxPrice();
      this.selectedType();
      this.startDate();
      this.endDate();
      this.minRating();
      this.sortBy();
      this.sortOrder();
      const mode = this.viewMode();
      untracked(() => {
        this.pageNumber.set(1);
        this.pageSize.set(mode === 'cards' ? 12 : 10);
      });
    });

    effect(() => {
      this.getData();
    });

    effect(() => {
      const catId = this.selectedCategoryId();
      if (catId) {
        this.loadSubcategories(catId);
      } else {
        this.subcategories.set([]);
        untracked(() => this.selectedSubcategoryId.set(undefined));
      }
    });
  }

  ngOnInit() {
    this.loadCategories();
  }

  loadCategories() {
    this.isLoadingCategories.set(true);
    this.categoriesClient.getCategories(1, 100)
      .pipe(
        tap(res => this.categories.set(res.data ?? [])),
        catchError(err => {
          this.toast.showError('errors.failedToLoadCategories');
          return of(null);
        }),
        finalize(() => this.isLoadingCategories.set(false))
      )
      .subscribe();
  }

  loadSubcategories(categoryId: number) {
    this.isLoadingSubcategories.set(true);
    this.subcategoriesClient.getSubcategories(1, 100, categoryId)
      .pipe(
        tap(res => this.subcategories.set(res.data ?? [])),
        catchError(err => {
          return of(null);
        }),
        finalize(() => this.isLoadingSubcategories.set(false))
      )
      .subscribe();
  }

  getData() {
    this.isLoading.set(true);
    const q = this.searchTerm().trim().toLowerCase();

    if (q && q.length > 0) {
      this.performSearch(q);
    } else {
      this.performGetItems();
    }
  }

  private performSearch(q: string) {
    this.searchClient.searchItems(
      q,
      this.pageNumber(),
      this.pageSize(),
      this.selectedCategoryId(),
      this.selectedCity()
    )
      .pipe(
        tap(res => {
          this.dataSource.set(res.data?.items ?? []);
          this.totalCount.set(res.data?.total ?? 0);
        }),
        catchError(err => {
          this.dataSource.set([]);
          this.toast.showError('errors.failedToLoadProducts');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false))
      )
      .subscribe();
  }

  private performGetItems() {
    this.apiClient.getItems(
        this.pageNumber(),
        this.pageSize(),
        this.selectedCategoryId() ?? undefined,
        this.selectedSubcategoryId() ?? undefined,
        this.selectedCity() ?? undefined,
        this.minPrice() ?? undefined,
        this.maxPrice() ?? undefined,
        this.startDate() ?? undefined,
        this.endDate() ?? undefined,
        this.minRating() ?? undefined,
        this.selectedType() ?? undefined,
        undefined,
        this.sortBy() ?? undefined,
        this.sortOrder() ?? undefined,
        undefined
      )
      .pipe(
        tap((response: any) => {
          this.dataSource.set(response?.data ?? []);
          this.totalCount.set(response?.total ?? 0);
        }),
        catchError((err: any) => {
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

  onFilterReset() {
    this.searchTerm.set('');
    this.selectedCategoryId.set(undefined);
    this.selectedSubcategoryId.set(undefined);
    this.selectedCity.set(undefined);
    this.minPrice.set(undefined);
    this.maxPrice.set(undefined);
    this.selectedType.set(undefined);
    this.startDate.set(undefined);
    this.endDate.set(undefined);
    this.minRating.set(undefined);
    this.sortBy.set('newest');
    this.sortOrder.set('desc');
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

  viewItem(id: string) {
    this.router.navigate(['/items', id]);
  }

  getPageTitle(): string {
    return 'products.title';
  }

  async deleteItem(id: string) {
    const item = this.dataSource().find((x: ItemListDto) => x.id === id);
    const isRemoved = item?.status === 'Removed' || item?.status === 'Suspended';
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: this.translate.instant(isRemoved ? 'products.permanentDelete' : 'common.reject'),
        message: this.translate.instant(
          isRemoved ? 'products.permanentDeleteConfirmation' : 'products.deactivateConfirmation'
        ),
        confirmText: this.translate.instant(isRemoved ? 'products.permanentDelete' : 'common.reject'),
        cancelText: this.translate.instant('buttons.cancel'),
      } as ConfirmDialogData,
      width: '480px',
    });

    const confirmed = await dialogRef.afterClosed().toPromise();
    if (confirmed) {
      this.isLoading.set(true);
      if (isRemoved) {
          this.apiClient.deleteItem(id).pipe(
              tap((res: any) => {
                  if (res.error) this.toast.showError(res.messages?.[0] || 'errors.unknownError');
                  else {
                      this.toast.showSuccess(res.messages?.[0] || 'products.permanentDeleteSuccess');
                      this.getData();
                  }
              }),
              catchError((err: any) => {
                  this.toast.showError('errors.unknownError');
                  return of(null);
              }),
              finalize(() => this.isLoading.set(false))
          ).subscribe();
      } else {
          this.adminClient.reviewItem(id, new ReviewItemCommand({ status: 'Suspended', rejectionReason: 'Suspended by Admin' }))
            .pipe(
              tap((res: any) => {
                if (res.error) {
                  this.toast.showError(res.messages?.[0] || 'errors.unknownError');
                } else {
                  this.toast.showSuccess(res.messages?.[0] || 'products.deactivateSuccess');
                  this.getData();
                }
              }),
              catchError(() => {
                this.toast.showError('errors.unknownError');
                return of(null);
              }),
              finalize(() => this.isLoading.set(false)),
            )
            .subscribe();
      }
    }
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
    this.adminClient.reviewItem(id, new ReviewItemCommand({ status: 'Available', rejectionReason: 'Reactivated by Admin' }))
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
    return item.status === 'Removed' || item.status === 'Suspended';
  }

  getLocalizedCatName(cat: ProductCategoryDto): string {
    return this.getLocalizedName(cat);
  }

  getLocalizedSubName(sub: ProductSubcategoryDto): string {
    return this.getLocalizedName(sub);
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
