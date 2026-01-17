import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
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
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ProductsClient, ProductListDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { ToastService } from '../../../shared/services/toast.service';
import { MatDialog } from '@angular/material/dialog';
import { ProductEditorPageComponent } from '../product-editor-page/product-editor-page.component';

@Component({
    selector: 'app-product-list',
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
        ProductEditorPageComponent
    ],
    templateUrl: './product-list.component.html',
    styleUrl: './product-list.component.scss'
})
export class ProductListComponent implements OnInit {
    private apiClient = inject(ProductsClient);
    private router = inject(Router);
    private dialog = inject(MatDialog);
    private toast = inject(ToastService);
    public translate = inject(TranslateService);

    displayedColumns = ['image', 'sku', 'name', 'price', 'subcategory', 'actions'];
    dataSource = signal<ProductListDto[]>([]);
    isLoading = signal(false);
    viewMode = signal<'list' | 'cards'>('list');

    // Pagination & Filtering state
    searchTerm = signal('');
    pageNumber = signal(1);
    pageSize = signal(10);
    totalCount = signal(0);

    // Sorting state
    sortBy = signal<string | null>('date');
    sortOrder = signal<'asc' | 'desc' | null>('desc');

    // Dialog state (added to fix errors)
    showDialog = signal(false);
    selectedProductId = signal<number | undefined>(undefined);

    constructor() {
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
        this.apiClient.getProducts(
            page,
            size,
            undefined, // subcategoryId
            undefined, // categoryId
            term || undefined,
            undefined, // minPrice
            undefined, // maxPrice
            undefined, // color
            this.sortBy() || undefined,
            this.sortOrder() || undefined
        )
            .pipe(
                tap((response) => {
                    this.dataSource.set(response.products?.items || []);
                    this.totalCount.set(response.products?.totalCount || 0);
                }),
                catchError((err) => {
                    console.error('Failed to load products', err);
                    this.dataSource.set([]);
                    this.toast.showError('errors.failedToLoadProducts');
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

    // Methods for dialog (added to fix errors)
    editProduct(id: number) {
        // Use router for now, matching existing logic
        this.router.navigate(['/products', id, 'edit']);
        /* 
        // If we were using dialog:
        this.selectedProductId.set(id);
        this.showDialog.set(true);
        */
    }

    createProduct() {
        this.router.navigate(['/products/new']);
        /*
        this.selectedProductId.set(undefined);
        this.showDialog.set(true);
        */
    }

    closeDialog() {
        this.showDialog.set(false);
        this.selectedProductId.set(undefined);
    }

    onSaved() {
        this.closeDialog();
        this.getData();
        this.toast.showSuccess('Product saved successfully');
    }

    async deleteProduct(id: number) {
        const dialogRef = this.dialog.open(ConfirmDialogComponent, {
            data: {
                title: this.translate.instant('products.actions.delete'),
                message: this.translate.instant('products.messages.deleteConfirmation'),
                confirmText: this.translate.instant('buttons.delete'),
                cancelText: this.translate.instant('buttons.cancel'),
            } as ConfirmDialogData,
            width: '480px',
        });

        const confirmed = await dialogRef.afterClosed().toPromise();
        if (confirmed) {
            this.isLoading.set(true);
            this.apiClient.deleteProduct(id)
                .pipe(
                    tap(() => {
                        this.toast.showSuccess('products.messages.deleteSuccess');
                        this.getData();
                    }),
                    catchError((err) => {
                        console.error('Delete failed', err);
                        this.toast.showError('errors.unknownError');
                        return of(null);
                    }),
                    finalize(() => this.isLoading.set(false))
                )
                .subscribe();
        }
    }
}
