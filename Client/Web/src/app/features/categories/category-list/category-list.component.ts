import { Component, inject, OnInit, signal, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatPaginatorModule, PageEvent, MatPaginator } from '@angular/material/paginator';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { CategoriesClient, ProductCategoryDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { CategoryEditorComponent } from '../category-editor/category-editor.component';

@Component({
    selector: 'app-category-list',
    standalone: true,
    imports: [
        CommonModule,
        TranslateModule,
        MatTableModule,
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
    public translate = inject(TranslateService);

    displayedColumns = ['logo', 'name', 'description', 'actions'];
    dataSource = signal<ProductCategoryDto[]>([]);
    isLoading = signal(false);
    viewMode = signal<'list' | 'cards'>('list');

    // Dialog state
    showDialog = signal(false);
    selectedCategoryId = signal<number | null>(null);

    // Pagination & Filtering state
    searchTerm: string = '';
    pageNumber: number = 1;
    pageSize: number = 10;
    totalCount: number = 0;

    @ViewChild(MatPaginator) paginator!: MatPaginator;

    ngOnInit() {
        this.getData();
    }

    private getData() {
        this.isLoading.set(true);
        this.apiClient.getCategories(
            this.pageNumber,
            this.pageSize,
            this.searchTerm || undefined
        )
            .pipe(
                tap((response) => {
                    this.dataSource.set(response.items || []);
                    this.totalCount = response.totalCount || 0;
                }),
                finalize(() => this.isLoading.set(false)),
                catchError(() => {
                    this.dataSource.set([]);
                    return of(null);
                })
            )
            .subscribe();
    }

    onSearchChange(event: any): void {
        const value = typeof event === 'string' ? event : (event.target as HTMLInputElement).value;
        this.searchTerm = value;
        this.pageNumber = 1;
        if (this.paginator) {
            this.paginator.pageIndex = 0;
        }
        this.getData();
    }

    onPageChange(event: PageEvent): void {
        this.pageNumber = event.pageIndex + 1;
        this.pageSize = event.pageSize;
        this.getData();
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
            this.apiClient.deleteCategory(id)
                .pipe(
                    tap(() => {
                        this.getData(); // Refresh data to update pagination if needed
                    }),
                    catchError(() => of(null))
                )
                .subscribe();
        }
    }
}
