import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Router, RouterModule } from '@angular/router';
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

import { ProductsClient, CategoriesClient, ProductListDto, ProductCategoryDto, SubcategoriesClient, ProductSubcategoryDto } from '../../core/api/api-client';
import { ToastService } from '../../shared/services/toast.service';
import { catchError, finalize, of, tap } from 'rxjs';

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
  ],
  templateUrl: './marketplace.component.html',
  styleUrl: './marketplace.component.scss'
})
export class MarketplaceComponent implements OnInit {
  private productsClient = inject(ProductsClient);
  private categoriesClient = inject(CategoriesClient);
  private subcategoriesClient = inject(SubcategoriesClient);
  private router = inject(Router);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  // Data
  products = signal<ProductListDto[]>([]);
  categories = signal<ProductCategoryDto[]>([]);
  subcategories = signal<ProductSubcategoryDto[]>([]);

  // Loading States
  isLoadingProducts = signal(false);
  isLoadingCategories = signal(false);
  isLoadingSubcategories = signal(false);

  // Filters
  searchTerm = signal('');
  selectedCategoryId = signal<number | undefined>(undefined);
  selectedSubcategoryId = signal<number | undefined>(undefined);

  // Pagination
  pageNumber = signal(1);
  pageSize = signal(12);
  totalCount = signal(0);

  constructor() {
    // Reset page when filters change
    effect(() => {
      const cat = this.selectedCategoryId();
      const sub = this.selectedSubcategoryId();
      const search = this.searchTerm();

      untracked(() => {
        this.pageNumber.set(1);
      });
    }, { allowSignalWrites: true });
    effect(() => {
      this.loadProducts();
    });
    effect(() => {
      const catId = this.selectedCategoryId();
      if (catId) {
        this.loadSubcategories(catId);
      } else {
        this.subcategories.set([]);
        this.selectedSubcategoryId.set(undefined);
      }
    }, { allowSignalWrites: true });
  }

  ngOnInit() {
    this.loadCategories();
  }

  loadCategories() {
    this.isLoadingCategories.set(true);
    this.categoriesClient.getCategories(1, 100, undefined)
      .pipe(
        tap(res => {
          this.categories.set(res.items || []);
        }),
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
    this.subcategoriesClient.getSubcategories(categoryId, 1, 100)
      .pipe(
        tap(res => {
          this.subcategories.set(res.subcategories?.items || []);
        }),
        catchError(err => {
          console.error('Failed to load subcategories', err);
          return of(null);
        }),
        finalize(() => this.isLoadingSubcategories.set(false))
      )
      .subscribe();
  }

  loadProducts() {
    this.isLoadingProducts.set(true);
    const page = this.pageNumber();
    const size = this.pageSize();
    const cat = this.selectedCategoryId();
    const sub = this.selectedSubcategoryId();
    const search = this.searchTerm();

    this.productsClient.getProducts(
      page,
      size,
      sub,
      cat,
      search || undefined,
      undefined, // minPrice
      undefined, // maxPrice
      undefined, // color
      'date', // sortBy
      'desc' // sortOrder
    ).pipe(
      tap(res => {
        if (res.products) {
          this.products.set(res.products.items || []);
          this.totalCount.set(res.products.totalCount || 0);
        }
      }),
      catchError(err => {
        this.toast.showError('errors.failedToLoadProducts');
        return of(null);
      }),
      finalize(() => this.isLoadingProducts.set(false))
    ).subscribe();
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
  }
}
