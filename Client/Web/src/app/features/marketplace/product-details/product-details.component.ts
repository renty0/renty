import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatChipsModule } from '@angular/material/chips';
import { MatTabsModule } from '@angular/material/tabs';
import { ItemsClient, ItemDetailDto, ItemListDto, FavoritesClient, ReviewsClient, ReviewDto, ChatClient, CreateChatCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { RentModalComponent } from '../../rentals/rent-modal/rent-modal';

import { catchError, finalize, of, tap } from 'rxjs';
import { ConfirmDialogComponent, ConfirmDialogData } from '../../../shared/components/confirm-dialog/confirm-dialog.component';
import { PermissionService } from '../../../core/services/permission.service';
import { PermissionType } from '../../../core/constants/permissions';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

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
        MatTabsModule,
        MatDividerModule,
        MatDialogModule,
        LoadingButtonComponent
    ],
    templateUrl: './product-details.component.html',
    styleUrl: './product-details.component.scss'
})
export class ProductDetailsComponent implements OnInit {
    private route = inject(ActivatedRoute);
    private itemsClient = inject(ItemsClient);
    private favoritesClient = inject(FavoritesClient);
    private reviewsClient = inject(ReviewsClient);
    private toast = inject(ToastService);
    private authService = inject(AuthService);
    public translate = inject(TranslateService);
    private router = inject(Router);
    private readonly dialog = inject(MatDialog);
    private readonly permissionService = inject(PermissionService);
    private chatClient = inject(ChatClient);

    item = signal<ItemDetailDto | null>(null);
    reviews = signal<ReviewDto[]>([]);
    relatedItems = signal<ItemListDto[]>([]);
    isLoading = signal(true);
    isFavorite = signal(false);
    isReminded = signal(false);
    isLoggedIn = this.authService.isLoggedIn;

    canEdit = computed(() => {
        if (this.isOwner()) return true;
        return this.permissionService.hasPermission(PermissionType.Items_Edit);
    });

    canDelete = computed(() => {
        if (this.isOwner()) return true;
        return this.permissionService.hasPermission(PermissionType.Items_Delete);
    });

    isOwner = computed(() => {
        const currentUserId = this.authService.getCurrentUserId();
        const itemOwnerId = this.item()?.owner?.id;
        return currentUserId !== null && !!itemOwnerId && currentUserId === itemOwnerId;
    });
    selectedImage = signal<string | undefined>(undefined);

    displayPrice = computed(() => {
        const item = this.item();
        if (!item) return 0;
        return item.pricing?.find(p => p.pricingType === 'Daily')?.price ??
            item.pricing?.[0]?.price ?? 0;
    });

    ngOnInit() {
        this.route.params.subscribe(params => {
            const id = params['id'];
            if (id) {
                this.loadItem(id);
            }
        });
    }

    loadItem(id: string) {
        this.isLoading.set(true);
        this.relatedItems.set([]);

        this.itemsClient.getItemById(id)
            .pipe(
                tap(res => {
                    if (!res.error && res.data) {
                        const itemData = res.data;
                        this.item.set(itemData);
                        // Set primary image
                        this.selectedImage.set(
                            itemData.images?.find(i => i.isPrimary)?.imageUrl ??
                            itemData.images?.[0]?.imageUrl
                        );
                        if (itemData.subcategory?.id) {
                            this.loadRelatedItems(itemData.subcategory.id, id);
                        }
                        this.loadReviews(id);
                        if (this.isLoggedIn()) {
                            this.checkIfFavorite(id);
                            this.checkReminderStatus(id);
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
    loadReviews(id: string) {
        this.reviewsClient.getItemReviews(id)
            .pipe(
                tap(res => {
                    if (res.data?.reviews) {
                        this.reviews.set(res.data.reviews);
                    }
                }),
                catchError(err => {
                    console.error('Failed to load reviews', err);
                    return of(null);
                })
            )
            .subscribe();
    }

    checkIfFavorite(id: string) {
        this.favoritesClient.getMyFavorites()
            .pipe(
                tap(res => {
                    if (res.data?.items) {
                        const isFav = res.data.items.some(i => i.id === id);
                        this.isFavorite.set(isFav);
                    }
                })
            )
            .subscribe();
    }

    checkReminderStatus(id: string) {
        this.itemsClient.getItemReminderStatus(id)
            .pipe(
                tap(res => {
                    if (res.data) {
                        this.isReminded.set(res.data.isReminded || false);
                    }
                })
            )
            .subscribe();
    }

    toggleReminder() {
        if (!this.isLoggedIn()) {
            this.router.navigate(['/login']);
            return;
        }

        const id = this.item()?.id;
        if (!id) return;

        const action = this.isReminded()
            ? this.itemsClient.removeItemReminder(id)
            : this.itemsClient.addItemReminder(id);

        action.pipe(
            tap(res => {
                if (!res.error) {
                    this.isReminded.set(!this.isReminded());
                    this.toast.showSuccess(this.isReminded() ? 'marketplace.reminderAdded' : 'marketplace.reminderRemoved');
                }
            }),
            catchError(err => {
                this.toast.showError('errors.generic');
                return of(null);
            })
        ).subscribe();
    }

    toggleFavorite() {
        if (!this.isLoggedIn()) {
            this.router.navigate(['/login']);
            return;
        }

        const id = this.item()?.id;
        if (!id) return;

        const action = this.isFavorite()
            ? this.favoritesClient.removeFavorite(id)
            : this.favoritesClient.addFavorite(id);

        action.pipe(
            tap(res => {
                if (!res.error) {
                    this.isFavorite.set(!this.isFavorite());
                    this.toast.showSuccess(this.isFavorite() ? 'marketplace.addToFavorites' : 'marketplace.removeFromFavorites');
                }
            }),
            catchError(err => {
                this.toast.showError('errors.generic');
                return of(null);
            })
        ).subscribe();
    }

    editItem() {
        const id = this.item()?.id;
        if (id) {
            this.router.navigate(['/items', id, 'edit']);
        }
    }

    deleteItem() {
        const id = this.item()?.id;
        if (!id) return;

        const dialogRef = this.dialog.open(ConfirmDialogComponent, {
            data: {
                title: this.translate.instant('buttons.delete'),
                message: this.translate.instant('products.deleteConfirmation'),
                confirmText: this.translate.instant('buttons.delete'),
                cancelText: this.translate.instant('buttons.cancel'),
                color: 'warn'
            } as ConfirmDialogData,
            width: '480px'
        });

        dialogRef.afterClosed().subscribe(confirmed => {
            if (confirmed) {
                this.itemsClient.deleteItem(id)
                    .pipe(
                        tap(res => {
                            if (!res.error) {
                                this.toast.showSuccess('products.deleteSuccess');
                                this.router.navigate(['/marketplace']);
                            }
                        }),
                        catchError(err => {
                            this.toast.showError('products.deleteFailed');
                            return of(null);
                        })
                    ).subscribe();
            }
        });
    }

    openRentModal() {
        if (!this.isLoggedIn()) {
            this.router.navigate(['/login']);
            return;
        }

        const itemData = this.item();
        if (!itemData) return;

        this.dialog.open(RentModalComponent, {
            width: '600px',
            data: { item: itemData },
            panelClass: 'rent-modal-container'
        }).afterClosed().subscribe(result => {
            if (result) {
                this.router.navigate(['/my-rentals']);
            }
        });
    }

    buyNow() {
        if (!this.isLoggedIn()) {
            this.router.navigate(['/login']);
            return;
        }

        const id = this.item()?.id;
        if (id) {
            this.router.navigate(['/checkout', id]);
        }
    }

    getLocalizedName(item: ItemDetailDto | ItemListDto | null): string {
        if (!item) return '';
        const isAr = this.translate.currentLang === 'ar';
        return isAr ? (item.titleAr || item.titleEn || '') : (item.titleEn || item.titleAr || '');
    }

    getLocalizedDesc(item: ItemDetailDto | null): string {
        if (!item) return '';
        const isAr = this.translate.currentLang === 'ar';
        return isAr ? (item.descAr || item.descEn || '') : (item.descEn || item.descAr || '');
    }

    getLocalizedRefName(ref: { nameAr?: string, nameEn?: string } | undefined | null): string {
        if (!ref) return '';
        const isAr = this.translate.currentLang === 'ar';
        return isAr ? (ref.nameAr || ref.nameEn || '') : (ref.nameEn || ref.nameAr || '');
    }

    startChat() {
        if (!this.isLoggedIn()) {
            this.router.navigate(['/login']);
            return;
        }

        const ownerId = this.item()?.owner?.id;
        if (!ownerId) return;

        const cmd = new CreateChatCommand({
            userId: ownerId,
            itemId: this.item()?.id as any
        });

        this.chatClient.createChat(cmd).subscribe({
            next: (res: any) => {
                const chatId = res?.data?.chatId || (res?.data as any)?.id;
                if (chatId) {
                    this.router.navigate(['/chats', chatId]);
                }
            },
            error: (err: any) => {
                console.error('Failed to start chat', err);
                this.toast.showError('errors.generic');
            }
        });
    }
}
