import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTabsModule } from '@angular/material/tabs';
import { ItemsClient, ItemDetailDto, ItemListDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
    selector: 'app-product-details',
    standalone: true,
    imports: [
        CommonModule,
        RouterModule,
        TranslateModule,
        MatButtonModule,
        MatIconModule,
        MatProgressSpinnerModule,
        MatChipsModule,
        MatTabsModule
    ],
    templateUrl: './product-details.component.html',
    styleUrl: './product-details.component.scss'
})
export class ProductDetailsComponent implements OnInit {
    private route = inject(ActivatedRoute);
    private itemsClient = inject(ItemsClient);
    private toast = inject(ToastService);

    item = signal<ItemDetailDto | null>(null);
    relatedItems = signal<ItemListDto[]>([]);
    isLoading = signal(true);
    selectedImage = signal<string | undefined>(undefined);

    ngOnInit() {
        this.route.params.subscribe(params => {
            const id = params['id'];
            if (id) {
                this.loadItem(id);  // id is a Guid string
            }
        });
    }

    loadItem(id: string) {
        this.isLoading.set(true);
        this.relatedItems.set([]);

        this.itemsClient.getItemById(id)
            .pipe(
                tap(res => {
                    if (res.success && res.data) {
                        const itemData = res.data;
                        this.item.set(itemData);
                        // Set primary image
                        this.selectedImage.set(
                            itemData.images?.find(i => i.isPrimary)?.imageUrl ??
                            itemData.images?.[0]?.imageUrl
                        );
                        // Load related items by subcategory if available
                        if (itemData.subcategory?.id) {
                            this.loadRelatedItems(itemData.subcategory.id, id);
                        }
                    }
                }),
                catchError(err => {
                    console.error('Failed to load item', err);
                    this.toast.showError('errors.failedToLoadProduct');
                    return of(null);
                }),
                finalize(() => this.isLoading.set(false))
            )
            .subscribe();
    }

    loadRelatedItems(subcategoryId: number, currentItemId: string) {
        this.itemsClient.getItems(
            1, 5,
            undefined,       // categoryId
            subcategoryId,   // subcategoryId
            undefined, undefined, undefined, undefined, undefined,
            'newest', 'desc', undefined
        )
            .pipe(
                tap(res => {
                    if (res.data) {
                        const filtered = res.data
                            .filter(i => i.id !== currentItemId)
                            .slice(0, 4);
                        this.relatedItems.set(filtered);
                    }
                }),
                catchError(err => {
                    console.error('Failed to load related items', err);
                    return of(null);
                })
            )
            .subscribe();
    }
}
