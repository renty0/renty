import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTabsModule } from '@angular/material/tabs';
import { ProductsClient, ProductDto, GetProductByIdResponse, ProductListDto } from '../../../core/api/api-client';
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
    private productsClient = inject(ProductsClient);
    private toast = inject(ToastService);

    product = signal<ProductDto | null>(null);
    relatedProducts = signal<ProductListDto[]>([]);
    isLoading = signal(true);
    selectedImage = signal<string | undefined>(undefined);

    ngOnInit() {
        this.route.params.subscribe(params => {
            const id = params['id'];
            if (id) {
                this.loadProduct(+id);
            }
        });
    }

    loadProduct(id: number) {
        this.isLoading.set(true);
        // Reset related products when loading new main product
        this.relatedProducts.set([]);

        this.productsClient.getProductById(id)
            .pipe(
                tap(res => {
                    if (res.product) {
                        this.product.set(res.product);
                        // Set initial main image
                        this.selectedImage.set(res.product.images?.find(i => i.isPrimary)?.imageUrl || res.product.images?.[0]?.imageUrl);

                        // Load related products based on category
                        if (res.product.subcategoryId) {
                            this.loadRelatedProducts(res.product.subcategoryId, res.product.id!);
                        }
                    }
                }),
                catchError(err => {
                    console.error('Failed to load product', err);
                    this.toast.showError('errors.failedToLoadProduct');
                    return of(null);
                }),
                finalize(() => this.isLoading.set(false))
            )
            .subscribe();
    }

    loadRelatedProducts(subcategoryId: number, currentProductId: number) {
        this.productsClient.getProducts(1, 4, subcategoryId)
            .pipe(
                tap(res => {
                    if (res.products && res.products.items) {
                        const filtered = res.products.items
                            .filter(p => p.id !== currentProductId)
                            .slice(0, 4); // Limit to 4 related products
                        this.relatedProducts.set(filtered);
                    }
                }),
                catchError(err => {
                    console.error('Failed to load related products', err);
                    return of(null);
                })
            )
            .subscribe();
    }
}
