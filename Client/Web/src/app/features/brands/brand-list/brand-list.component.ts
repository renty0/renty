import { Component, inject, OnInit, signal, effect, untracked, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatButtonToggleModule, MatButtonToggleChange } from '@angular/material/button-toggle';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { firstValueFrom } from 'rxjs';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { BrandsClient, BrandDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { BrandEditorComponent } from '../brand-editor/brand-editor.component';
import { ToastService } from '../../../shared/services/toast.service';

type ViewMode = 'list' | 'cards';

@Component({
  selector: 'app-brand-list',
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
    BrandEditorComponent,
  ],
  templateUrl: './brand-list.component.html',
  styleUrl: './brand-list.component.scss',
})
export class BrandListComponent implements OnInit {
  private readonly apiClient = inject(BrandsClient);
  private readonly dialog = inject(MatDialog);
  private readonly toast = inject(ToastService);
  private readonly translate = inject(TranslateService);
  private readonly destroyRef = inject(DestroyRef);

  readonly displayedColumns = ['logo', 'name', 'description', 'items', 'actions'] as const;
  readonly dataSource = signal<BrandDto[]>([]);
  readonly isLoading = signal(false);
  readonly viewMode = signal<ViewMode>('cards');

  readonly showDialog = signal(false);
  readonly selectedBrandId = signal<number | null>(null);

  readonly searchTerm = signal('');
  readonly pageNumber = signal(1);
  readonly pageSize = signal(10);
  readonly totalCount = signal(0);

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
      this.loadBrands();
    });
  }

  ngOnInit(): void {}

  private loadBrands(): void {
    this.isLoading.set(true);
    this.apiClient
      .getBrands(
        this.pageNumber(),
        this.pageSize(),
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
          this.toast.showError(this.translate.instant('brands.errors.failedToLoad'));
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe();
  }

  onSearchChange(event: Event | string): void {
    const value =
      typeof event === 'string' ? event : ((event.target as HTMLInputElement)?.value ?? '');
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

  onViewModeChange(change: MatButtonToggleChange): void {
    this.viewMode.set(change.value as ViewMode);
  }

  openEditor(id: number | null): void {
    this.selectedBrandId.set(id);
    this.showDialog.set(true);
  }

  closeDialog(): void {
    this.showDialog.set(false);
    this.selectedBrandId.set(null);
  }

  onSaved(): void {
    this.closeDialog();
    this.loadBrands();
  }

  async deleteBrand(brand: BrandDto) {
    const id = brand.id;
    if (id == null) return;

    const data: ConfirmDialogData = {
      title: this.translate.instant('brands.actions.delete'),
      message: this.translate.instant('brands.messages.deleteConfirmation'),
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
      .deleteBrand(id)
      .pipe(
        tap(() => {
          this.toast.showSuccess(this.translate.instant('brands.messages.deleteSuccess'));
          this.loadBrands();
        }),
        catchError(() => {
          this.toast.showError(this.translate.instant('brands.errors.failedToDelete'));
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe();
  }

  placeholderLogo = 'assets/images/placeholder.png';

  truncate(text: string | undefined, maxLen: number): string {
    if (!text) return '';
    return text.length <= maxLen ? text : text.slice(0, maxLen) + '...';
  }

  getLocalizedName(brand: BrandDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? brand.nameAr || brand.nameEn || '' : brand.nameEn || brand.nameAr || '';
  }

  getLocalizedDesc(brand: BrandDto): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? brand.descAr || brand.descEn || '' : brand.descEn || brand.descAr || '';
  }
}
