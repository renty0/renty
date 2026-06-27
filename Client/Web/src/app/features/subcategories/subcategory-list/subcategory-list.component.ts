import { Component, inject, OnInit, signal, effect, untracked, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { firstValueFrom } from 'rxjs';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ProductSubcategoryDto, SubcategoriesClient } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { SubcategoryEditorComponent } from '../subcategory-editor/subcategory-editor.component';
import { ToastService } from '../../../shared/services/toast.service';

type ViewMode = 'list' | 'cards';

@Component({
  selector: 'app-subcategory-list',
  standalone: true,
  imports: [
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
    SubcategoryEditorComponent
],
  templateUrl: './subcategory-list.component.html',
  styleUrl: './subcategory-list.component.scss',
})
export class SubcategoryListComponent implements OnInit {
  private readonly apiClient = inject(SubcategoriesClient);
  private readonly dialog = inject(MatDialog);
  private readonly toast = inject(ToastService);
  private readonly translate = inject(TranslateService);
  private readonly destroyRef = inject(DestroyRef);

  readonly displayedColumns = ['logo', 'name', 'category', 'description', 'actions'] as const;
  readonly dataSource = signal<ProductSubcategoryDto[]>([]);
  readonly isLoading = signal(false);
  readonly viewMode = signal<ViewMode>('cards');

  readonly showDialog = signal(false);
  readonly selectedSubcategoryId = signal<number | null>(null);

  readonly searchTerm = signal('');
  readonly pageNumber = signal(1);
  readonly pageSize = signal(10);
  readonly totalCount = signal(0);
  refreshTime = signal(Date.now());

  readonly sortBy = signal<string | null>('nameEn');
  readonly sortOrder = signal<'asc' | 'desc' | null>('asc');

  constructor() {
    effect(() => {
      const mode = this.viewMode();
      untracked(() => {
        this.pageNumber.set(1);
        this.pageSize.set(mode === 'cards' ? 12 : 10);
      });
    });

    effect(() => {
      this.getData();
    });
  }

  ngOnInit() {}

  private getData(): void {
    this.isLoading.set(true);
    this.apiClient
      .getSubcategories(
        this.pageNumber(),
        this.pageSize(),
        undefined,
        this.searchTerm() || undefined,
        this.sortBy() || undefined,
        this.sortOrder() || undefined,
      )
      .pipe(
        tap((res) => {
          this.dataSource.set(res?.data ?? []);
          this.totalCount.set(res?.total ?? 0);
        }),
        catchError((err) => {
          this.dataSource.set([]);
          this.toast.showError(err.messages?.[0]);
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
        takeUntilDestroyed(this.destroyRef),
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

  createSubcategory(): void {
    this.selectedSubcategoryId.set(null);
    this.showDialog.set(true);
  }

  editSubcategory(id: number): void {
    this.selectedSubcategoryId.set(id);
    this.showDialog.set(true);
  }

  async deleteSubcategory(id: number): Promise<void> {
    const data: ConfirmDialogData = {
      title: this.translate.instant('buttons.delete'),
      message: this.translate.instant('subcategories.messages.deleteConfirmation'),
      confirmText: this.translate.instant('buttons.delete'),
      cancelText: this.translate.instant('buttons.cancel'),
    };

    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data,
      width: '480px',
    });

    const confirmed = await firstValueFrom(dialogRef.afterClosed());
    if (!confirmed) return;

    this.isLoading.set(true);
    this.apiClient
      .deleteSubcategory(id)
      .pipe(
        tap((res) => {
          if (res && !res.error) {
            this.toast.showSuccess(res.messages?.[0] || '');
            this.dataSource.update((current) => current.filter((s) => s.id !== id));
            this.totalCount.update((t) => Math.max(0, t - 1));
          } else {
            this.toast.showError(res?.messages?.[0] || '');
          }
        }),
        catchError((err) => {
          this.toast.showError(err.messages?.[0] || '');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe();
  }

  closeDialog(): void {
    this.showDialog.set(false);
    this.selectedSubcategoryId.set(null);
  }

  onSaved(subcategory: ProductSubcategoryDto): void {
    this.closeDialog();
    this.dataSource.update((current) => {
      const index = current.findIndex((s) => s.id === subcategory.id);
      if (index !== -1) {
        const updated = [...current];
        updated[index] = subcategory;
        return updated;
      }
      return [subcategory, ...current];
    });
    if (this.selectedSubcategoryId() === null) {
      this.totalCount.update((t) => t + 1);
    }
    this.refreshTime.set(Date.now());
  }

  truncate(text: string | undefined, maxLen: number): string {
    if (!text) return '';
    return text.length <= maxLen ? text : text.slice(0, maxLen) + '...';
  }

  getLogoUrl(url: string | undefined): string {
    if (!url) return 'assets/images/placeholder.png';
    return `${url}?t=${this.refreshTime()}`;
  }

  getLocalizedName(row: ProductSubcategoryDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? row.nameAr || row.nameEn || '' : row.nameEn || row.nameAr || '';
  }

  getLocalizedDesc(row: ProductSubcategoryDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? row.descAr || row.descEn || '' : row.descEn || row.descAr || '';
  }

  getLocalizedCatName(row: ProductSubcategoryDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr
      ? row.categoryNameAr || row.categoryNameEn || ''
      : row.categoryNameEn || row.categoryNameAr || '';
  }
}
