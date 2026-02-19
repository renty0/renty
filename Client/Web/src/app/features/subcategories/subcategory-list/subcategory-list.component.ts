import { Component, inject, OnInit, signal, ViewChild, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatSortModule, Sort } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent, MatPaginator } from '@angular/material/paginator';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ProductSubcategoryDto, SubcategoriesClient } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { SubcategoryEditorComponent } from '../subcategory-editor/subcategory-editor.component';
import { ToastService } from '../../../shared/services/toast.service';
import { LocalizationService } from '../../../core/services/localization.service';

@Component({
  selector: 'app-subcategory-list',
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
    SubcategoryEditorComponent,
  ],
  templateUrl: './subcategory-list.component.html',
  styleUrl: './subcategory-list.component.scss',
})
export class SubcategoryListComponent implements OnInit {
  private apiClient = inject(SubcategoriesClient);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);
  public localization = inject(LocalizationService);

  displayedColumns = ['logo', 'name', 'category', 'description', 'actions'];
  dataSource = signal<ProductSubcategoryDto[]>([]);
  isLoading = signal(false);
  viewMode = signal<'list' | 'cards'>('list');

  // Dialog state
  showDialog = signal(false);
  selectedSubcategoryId = signal<number | null>(null);

  // Pagination & Filtering state
  searchTerm = signal('');
  pageNumber = signal(1);
  pageSize = signal(10);
  totalCount = signal(0);
  lang = this.localization.language;

  // Sorting state
  sortBy = signal<string | null>('date');
  sortOrder = signal<'asc' | 'desc' | null>('desc');

  constructor() {
    // Adjust page settings when view mode changes
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

    // Reactive data fetching
    effect(
      () => {
        this.getData();
      },
      { allowSignalWrites: true },
    );
  }

  ngOnInit() {}

  private getData() {
    const page = this.pageNumber();
    const size = this.pageSize();
    const term = this.searchTerm();

    this.isLoading.set(true);
    this.apiClient
      .getSubcategories(
        undefined,
        page,
        size,
        term || undefined,
        this.sortBy() || undefined,
        this.sortOrder() || undefined,
      )
      .pipe(
        tap((response) => {
          const items = response.subcategories?.items || [];
          this.dataSource.set(items);
          this.totalCount.set(response.subcategories?.totalCount || 0);
        }),
        catchError((err) => {
          console.error('Failed to load subcategories', err);
          this.dataSource.set([]);
          this.toast.showError('errors.failedToLoadSubcategories');
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

  createSubcategory() {
    this.selectedSubcategoryId.set(null);
    this.showDialog.set(true);
  }

  editSubcategory(id: number) {
    this.selectedSubcategoryId.set(id);
    this.showDialog.set(true);
  }

  deleteSubcategory(id: number) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '400px',
      data: {
        title: 'subcategories.actions.delete',
        message: 'subcategories.messages.deleteConfirmation',
        confirmText: 'buttons.delete',
        cancelText: 'buttons.cancel',
      } as ConfirmDialogData,
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result) {
        this.isLoading.set(true);
        this.apiClient
          .deleteSubcategory(id)
          .pipe(
            tap(() => {
              this.getData();
            }),
            finalize(() => this.isLoading.set(false)),
          )
          .subscribe();
      }
    });
  }

  closeDialog() {
    this.showDialog.set(false);
    this.selectedSubcategoryId.set(null);
  }

  onSaved(subcategory: ProductSubcategoryDto) {
    this.closeDialog();
    this.getData();
  }
}
