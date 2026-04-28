import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatChipsModule } from '@angular/material/chips';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';

import {
  ItemsClient,
  ItemListDto,
  CategoriesClient,
  SubcategoriesClient,
  ProductCategoryDto,
  ProductSubcategoryDto,
  SearchClient,
} from '../../core/api/api-client';
import { ToastService } from '../../shared/services/toast.service';
import { ProductCardComponent } from '../../shared/components/product-card/product-card.component';
import { catchError, finalize, of, tap } from 'rxjs';
import { EGYPT_GOVERNORATES } from '../items/items-editor-page/items-editor.constants';

@Component({
  selector: 'app-marketplace',
  standalone: true,
  imports: [
    CommonModule,
    TranslateModule,
    RouterModule,
    FormsModule,
    MatIconModule,
    MatButtonModule,
    MatInputModule,
    MatSelectModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatPaginatorModule,
    MatExpansionModule,
    MatChipsModule,
    MatFormFieldModule,
    MatDatepickerModule,
    MatNativeDateModule,
    ProductCardComponent
  ],
  templateUrl: './marketplace.component.html',
  styleUrl: './marketplace.component.scss'
})
export class MarketplaceComponent implements OnInit {
  private itemsClient = inject(ItemsClient);
  private searchClient = inject(SearchClient);
  private categoriesClient = inject(CategoriesClient);
  private subcategoriesClient = inject(SubcategoriesClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  // Data
  items = signal<ItemListDto[]>([]);
  categories = signal<ProductCategoryDto[]>([]);
  subcategories = signal<ProductSubcategoryDto[]>([]);

  governorates = EGYPT_GOVERNORATES;

  itemTypes = [
    { key: 'standard', name: 'labels.types.standard' },
    { key: 'premium', name: 'labels.types.premium' }
  ];

  // Loading States
  isLoadingItems = signal(false);
  isLoadingCategories = signal(false);
  isLoadingSubcategories = signal(false);

  // Filters
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
  sortBy = signal<string>('newest');

  // Pagination
  pageNumber = signal(1);
  pageSize = signal(12);
  totalCount = signal(0);

  constructor() {
    // Reset page when filters change
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
      untracked(() => this.pageNumber.set(1));
    }, { allowSignalWrites: true });

    // Load items reactively
    effect(() => {
      this.loadItems();
    });

    // Load subcategories when category changes
    effect(() => {
      const catId = this.selectedCategoryId();
      if (catId) {
        this.loadSubcategories(catId);
      } else {
        this.subcategories.set([]);
        untracked(() => this.selectedSubcategoryId.set(undefined));
      }
    }, { allowSignalWrites: true });
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
          console.error('Failed to load categories', err);
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
          console.error('Failed to load subcategories', err);
          return of(null);
        }),
        finalize(() => this.isLoadingSubcategories.set(false))
      )
      .subscribe();
  }

  loadItems() {
    this.isLoadingItems.set(true);
    const q = this.searchTerm();

    if (q && q.trim().length > 0) {
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
          this.items.set(res.data?.items ?? []);
          this.totalCount.set(res.data?.total ?? 0);
        }),
        catchError(err => {
          this.toast.showError('errors.failedToLoadProducts');
          return of(null);
        }),
        finalize(() => this.isLoadingItems.set(false))
      )
      .subscribe();
  }

  private performGetItems() {
    let sort: string | undefined = undefined;
    let sortOrder: string | undefined = undefined;

    switch (this.sortBy()) {
      case 'price_low':
        sort = 'price';
        sortOrder = 'asc';
        break;
      case 'price_high':
        sort = 'price';
        sortOrder = 'desc';
        break;
      case 'rating':
        sort = 'rating';
        sortOrder = 'desc';
        break;
      case 'newest':
      default:
        sort = 'createdAt';
        sortOrder = 'desc';
        break;
    }

    this.itemsClient.getItems(
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
      undefined,              // condition
      sort,
      sortOrder,
      undefined               // owner
    )
      .pipe(
        tap(res => {
          this.items.set(res.data ?? []);
          this.totalCount.set(res?.total ?? 0);
        }),
        catchError(err => {
          this.toast.showError('errors.failedToLoadProducts');
          return of(null);
        }),
        finalize(() => this.isLoadingItems.set(false))
      )
      .subscribe();
  }

  onPageChange(event: PageEvent) {
    this.pageNumber.set(event.pageIndex + 1);
    this.pageSize.set(event.pageSize);
    window.scrollTo({ top: 0, behavior: 'smooth' });
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
  }

  getLocalizedCatName(cat: ProductCategoryDto): string {
    return this.getLocalizedRefName(cat);
  }

  getLocalizedSubName(sub: ProductSubcategoryDto): string {
    return this.getLocalizedRefName(sub);
  }

  getLocalizedRefName(ref: { nameAr?: string, nameEn?: string } | undefined | null): string {
    if (!ref) return '';
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (ref.nameAr || ref.nameEn || '') : (ref.nameEn || ref.nameAr || '');
  }

  getLocalizedTitle(item: ItemListDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (item.titleAr || item.titleEn || '') : (item.titleEn || item.titleAr || '');
  }
}
