import { Component, inject, OnInit, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { SearchClient, ItemListDto } from '../../core/api/api-client';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
  selector: 'app-search-results',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatPaginatorModule
  ],
  templateUrl: './search-results.component.html',
  styleUrl: './search-results.component.scss'
})
export class SearchResultsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private searchClient = inject(SearchClient);
  public translate = inject(TranslateService);

  query = signal('');
  items = signal<ItemListDto[]>([]);
  isLoading = signal(false);
  
  // Pagination
  pageNumber = signal(1);
  pageSize = signal(12);
  totalCount = signal(0);

  constructor() {
    // React to query param changes
    this.route.queryParams.subscribe(params => {
      const q = params['q'] || '';
      this.query.set(q);
      this.pageNumber.set(1);
      this.loadResults();
    });
  }

  ngOnInit() {}

  loadResults() {
    const q = this.query();
    if (!q) {
      this.items.set([]);
      this.totalCount.set(0);
      return;
    }

    this.isLoading.set(true);
    this.searchClient.searchItems(
      q,
      this.pageNumber(),
      this.pageSize()
    )
    .pipe(
      tap(res => {
        this.items.set(res.data?.items ?? []);
        this.totalCount.set(res.data?.total ?? 0);
      }),
      catchError(err => {
        console.error('Search failed', err);
        return of(null);
      }),
      finalize(() => this.isLoading.set(false))
    )
    .subscribe();
  }

  onPageChange(event: PageEvent) {
    this.pageNumber.set(event.pageIndex + 1);
    this.pageSize.set(event.pageSize);
    this.loadResults();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  getLocalizedTitle(item: any): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (item.titleAr || item.titleEn || '') : (item.titleEn || item.titleAr || '');
  }

  getLocalizedRefName(ref: any): string {
    if (!ref) return '';
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (ref.nameAr || ref.nameEn || '') : (ref.nameEn || ref.nameAr || '');
  }
}

