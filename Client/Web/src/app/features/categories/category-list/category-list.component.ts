import { Component, inject, OnInit, signal, ViewChild, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
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
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { CategoriesClient, ProductCategoryDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { CategoryEditorComponent } from '../category-editor/category-editor.component';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
    selector: 'app-category-list',
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
        CategoryEditorComponent
    ],
    templateUrl: './category-list.component.html',
    styleUrl: './category-list.component.scss'
})
export class CategoryListComponent implements OnInit {
    private apiClient = inject(CategoriesClient);
    private dialog = inject(MatDialog);
    private toast = inject(ToastService);
    public translate = inject(TranslateService);

    displayedColumns = ['logo', 'name', 'description', 'actions'];
    dataSource = signal<ProductCategoryDto[]>([]);
    isLoading = signal(false);
    viewMode = signal<'list' | 'cards'>('list');

    // Dialog state
    showDialog = signal(false);
    selectedCategoryId = signal<number | null>(null);

    // Pagination & Filtering state
    searchTerm = signal('');
    pageNumber = signal(1);
    pageSize = signal(10);
    totalCount = signal(0);

    // Sorting state
    sortBy = signal<string | null>('date');
    sortOrder = signal<'asc' | 'desc' | null>('desc');

    constructor() {
        // Adjust page settings when view mode changes
        effect(() => {
            const mode = this.viewMode();
            untracked(() => {
                this.pageNumber.set(1);
                this.pageSize.set(mode === 'cards' ? 12 : 10);
            });
        }, { allowSignalWrites: true });

        // Reactive data fetching
        effect(() => {
            this.getData();
        }, { allowSignalWrites: true });
    }

    ngOnInit() {
    }

    private getData() {
        const page = this.pageNumber();
        const size = this.pageSize();
        const term = this.searchTerm();

        this.isLoading.set(true);
        this.apiClient.getCategories(
            page,
            size,
            term || undefined,
            this.sortBy() || undefined,
            this.sortOrder() || undefined
        )
            .pipe(
                tap((response) => {
                    this.dataSource.set(response?.data || []);
                    this.totalCount.set(response?.total || 0);
                }),
                catchError((err) => {
                    console.error('Failed to load categories', err);
                    this.dataSource.set([]);
                    this.toast.showError('errors.failedToLoadCategories');
                    return of(null);
                }),
                finalize(() => this.isLoading.set(false))
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
        this.sortOrder.set(sort.direction ? sort.direction as 'asc' | 'desc' : null);
        this.pageNumber.set(1);
    }

    editCategory(id: number) {
        this.selectedCategoryId.set(id);
        this.showDialog.set(true);
    }

    createCategory() {
        this.selectedCategoryId.set(null);
        this.showDialog.set(true);
    }

    closeDialog() {
        this.showDialog.set(false);
        this.selectedCategoryId.set(null);
    }

    onSaved() {
        this.closeDialog();
        this.getData();
    }

    async deleteCategory(id: number) {
        const dialogRef = this.dialog.open(ConfirmDialogComponent, {
            data: {
                title: this.translate.instant('categories.actions.delete'),
                message: this.translate.instant('categories.confirmDelete'),
                confirmText: this.translate.instant('buttons.delete'),
                cancelText: this.translate.instant('buttons.cancel'),
            } as ConfirmDialogData,
            width: '480px',
        });

        const confirmed = await dialogRef.afterClosed().toPromise();
        if (confirmed) {
            this.isLoading.set(true);
            this.apiClient.deleteCategory(id)
                .pipe(
                    tap(() => {
                        this.getData();
                    }),
                    catchError(() => of(null)),
                    finalize(() => this.isLoading.set(false))
                )
                .subscribe();
        }
    }
}
