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
import { ItemsClient, ItemListDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { ToastService } from '../../../shared/services/toast.service';
import { MatDialog } from '@angular/material/dialog';

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
    ],
    templateUrl: './product-list.component.html',
    styleUrl: './product-list.component.scss'
})
export class ProductListComponent implements OnInit {
    private apiClient = inject(ItemsClient);
    private router = inject(Router);
    private dialog = inject(MatDialog);
    private toast = inject(ToastService);
    public translate = inject(TranslateService);

    displayedColumns = ['image', 'title', 'price', 'category', 'actions'];
    dataSource = signal<ItemListDto[]>([]);
    isLoading = signal(false);
    viewMode = signal<'list' | 'cards'>('list');

    // Pagination & Filtering state
    searchTerm = signal('');
    pageNumber = signal(1);
    pageSize = signal(10);
    totalCount = signal(0);

    // Sorting state
    sortBy = signal<string | null>('newest');
    sortOrder = signal<'asc' | 'desc' | null>('desc');

    constructor() {
        effect(() => {
            const mode = this.viewMode();
            untracked(() => {
                this.pageNumber.set(1);
                this.pageSize.set(mode === 'cards' ? 12 : 10);
            });
        }, { allowSignalWrites: true });

        effect(() => {
            this.getData();
        }, { allowSignalWrites: true });
    }

    ngOnInit() { }

    private getData() {
        const page = this.pageNumber();
        const limit = this.pageSize();

        this.isLoading.set(true);
        this.apiClient.getItems(
            page,
            limit,
            undefined,  // categoryId
            undefined,  // subcategoryId
            undefined,  // city
            undefined,  // minPrice
            undefined,  // maxPrice
            undefined,  // type
            undefined,  // condition
            this.sortBy() ?? undefined,
            this.sortOrder() ?? undefined,
            undefined   // owner
        )
            .pipe(
                tap((response) => {
                    this.dataSource.set(response?.data ?? []);
                    this.totalCount.set(response?.total ?? 0);
                }),
                catchError((err) => {
                    console.error('Failed to load items', err);
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

    editItem(id: string) {
        this.router.navigate(['/products', id, 'edit']);
    }

    createItem() {
        this.router.navigate(['/products/new']);
    }

    async deleteItem(id: string) {
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
            this.apiClient.deleteItem(id)
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
