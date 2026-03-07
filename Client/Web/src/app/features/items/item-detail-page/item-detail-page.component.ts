import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ItemsClient, ItemDetailDto } from '../../../core/api/api-client';
import { LocalizationService } from '../../../core/services/localization.service';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
    selector: 'app-item-detail-page',
    standalone: true,
    imports: [
        CommonModule,
        RouterModule,
        TranslateModule,
        MatButtonModule,
        MatIconModule,
        MatChipsModule,
        MatProgressSpinnerModule,
    ],
    templateUrl: './item-detail-page.component.html',
    styleUrl: './item-detail-page.component.scss',
})
export class ItemDetailPageComponent implements OnInit {
    private itemsClient = inject(ItemsClient);
    private route = inject(ActivatedRoute);
    private router = inject(Router);
    private localization = inject(LocalizationService);

    item = signal<ItemDetailDto | null>(null);
    isLoading = signal(false);
    activeImageIndex = signal(0);

    get lang() {
        return this.localization.language();
    }

    ngOnInit() {
        this.route.params.subscribe((params) => {
            const id = params['id'];
            if (id) {
                this.loadItem(id);
            } else {
                this.router.navigate(['/items']);
            }
        });
    }

    loadItem(id: string) {
        this.isLoading.set(true);
        this.itemsClient
            .getItemById(id)
            .pipe(
                tap((res: any) => {
                    console.log('Item response:', res);
                    const itemData = res.data?.item || res.data;
                    if (itemData && !res.data?.found === false) {
                        this.item.set(itemData);
                        const primaryIdx = itemData.images?.findIndex((img: any) => img.isPrimary) ?? 0;
                        this.activeImageIndex.set(primaryIdx >= 0 ? primaryIdx : 0);
                    } else {
                        console.warn('Item not found or empty data:', res.data?.error || 'No error message');
                        this.router.navigate(['/items']);
                    }
                }),
                catchError((err) => {
                    console.error('Error loading item:', err);
                    this.router.navigate(['/items']);
                    return of(null);
                }),
                finalize(() => this.isLoading.set(false))
            )
            .subscribe();
    }

    setActiveImage(index: number) {
        this.activeImageIndex.set(index);
    }

    get dailyPrice(): number {
        return this.item()?.pricing?.find(p => p.pricingType === 'daily')?.price ?? 0;
    }
}
