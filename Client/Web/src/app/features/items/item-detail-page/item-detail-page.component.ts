import {
    Component, inject, OnInit, signal, ChangeDetectionStrategy, ChangeDetectorRef, DestroyRef
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDividerModule } from '@angular/material/divider';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { catchError, finalize, of, tap } from 'rxjs';

import {
    ItemsClient, ItemDetailDto, FavoritesClient, ReviewsClient, ChatClient,
    GetItemReviewsResponse, ReviewDto, ItemListDto, CreateChatCommand, CreateReviewCommand,
    BookedRangeDto
} from '../../../core/api/api-client';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { LocalizationService } from '../../../core/services/localization.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent } from '../../../shared/components/input/input';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
    selector: 'app-item-detail-page',
    standalone: true,
    imports: [
        CommonModule,
        RouterModule,
        ReactiveFormsModule,
        TranslateModule,
        MatIconModule,
        MatChipsModule,
        MatProgressSpinnerModule,
        MatTooltipModule,
        MatDividerModule,
        MatDatepickerModule,
        MatNativeDateModule,
        LoadingButtonComponent,
        InputComponent,
    ],
    templateUrl: './item-detail-page.component.html',
    styleUrl: './item-detail-page.component.scss',
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ItemDetailPageComponent implements OnInit {
    private readonly itemsClient = inject(ItemsClient);
    private readonly favoritesClient = inject(FavoritesClient);
    private readonly reviewsClient = inject(ReviewsClient);
    private readonly chatClient = inject(ChatClient);
    private readonly route = inject(ActivatedRoute);
    private readonly router = inject(Router);
    private readonly localization = inject(LocalizationService);
    private readonly fb = inject(FormBuilder);
    private readonly toast = inject(ToastService);
    private readonly translate = inject(TranslateService);
    private readonly cdr = inject(ChangeDetectorRef);
    private readonly destroyRef = inject(DestroyRef);

    // ── State signals ──────────────────────────────────────────────
    item = signal<ItemDetailDto | null>(null);
    activeImageIndex = signal(0);
    isLoading = signal(false);
    isFavoriting = signal(false);
    isRenting = signal(false);
    isChatting = signal(false);
    isReminded = signal(false);
    bookedDates = signal<BookedRangeDto[]>([]);
    isLoadingAvailability = signal(false);

    // ── Reviews ────────────────────────────────────────────────────
    reviewsData = signal<GetItemReviewsResponse | null>(null);
    isLoadingReviews = signal(false);
    isSubmittingReview = signal(false);
    hoveredStar = signal(0);
    selectedStar = signal(0);

    // ── Similar items ──────────────────────────────────────────────
    similarItems = signal<ItemListDto[]>([]);
    isLoadingSimilar = signal(false);

    // ── Forms ──────────────────────────────────────────────────────
    reviewForm!: FormGroup;

    get lang() { return this.localization.language(); }

    get dailyPrice(): number {
        return this.item()?.pricing?.find(p => p.pricingType === 'daily')?.price ?? 0;
    }
    get weeklyPrice(): number {
        return this.item()?.pricing?.find(p => p.pricingType === 'weekly')?.price ?? 0;
    }
    get monthlyPrice(): number {
        return this.item()?.pricing?.find(p => p.pricingType === 'monthly')?.price ?? 0;
    }
    get avgRating(): number { return this.reviewsData()?.avgRating ?? this.item()?.avgRating ?? 0; }
    get reviewCount(): number { return this.reviewsData()?.totalReviews ?? this.item()?.reviewCount ?? 0; }
    get reviews(): ReviewDto[] { return this.reviewsData()?.reviews ?? []; }

    /** Returns the count of reviews for each star level (5 → 1). */
    getStarCount(star: number): number {
        return this.reviews.filter(r => Math.round(r.rating ?? 0) === star).length;
    }
    getStarPercent(star: number): number {
        if (!this.reviewCount) return 0;
        return Math.round((this.getStarCount(star) / this.reviewCount) * 100);
    }
    starsArray(rating: number): number[] {
        return Array.from({ length: 5 }, (_, i) => i + 1);
    }

    ngOnInit(): void {
        this.reviewForm = this.fb.group({
            comment: ['', [Validators.required, Validators.minLength(10)]],
        });

        this.route.params
            .pipe(takeUntilDestroyed(this.destroyRef))
            .subscribe(params => {
                const id = params['id'];
                if (id) {
                    this.activeImageIndex.set(0);
                    this.loadItem(id);
                    this.loadReviews(id);
                    this.loadAvailability(id);
                } else {
                    this.router.navigate(['/items']);
                }
            });
    }

    loadItem(id: string): void {
        this.isLoading.set(true);
        this.itemsClient.getItemById(id).pipe(
            tap((res) => {
                const data = res?.data;
                if (!res?.error && data) {
                    this.item.set(data);
                    const primaryIdx = data.images?.findIndex((img) => img.isPrimary) ?? 0;
                    this.activeImageIndex.set(primaryIdx >= 0 ? primaryIdx : 0);
                    this.loadSimilarItems(data.category?.id, id);
                    this.checkReminderStatus(id);
                } else {
                    this.router.navigate(['/items']);
                }
            }),
            catchError(() => { this.router.navigate(['/items']); return of(null); }),
            finalize(() => { this.isLoading.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    loadReviews(itemId: string): void {
        this.isLoadingReviews.set(true);
        this.reviewsClient.getItemReviews(itemId).pipe(
            tap((res) => {
                const data = res?.data;
                if (!res?.error && data) this.reviewsData.set(data);
            }),
            catchError(() => of(null)),
            finalize(() => { this.isLoadingReviews.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    loadAvailability(itemId: string): void {
        this.isLoadingAvailability.set(true);
        this.itemsClient.getItemAvailability(itemId).pipe(
            tap((res) => {
                this.bookedDates.set(res?.data || []);
            }),
            catchError(() => of(null)),
            finalize(() => { this.isLoadingAvailability.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    loadSimilarItems(categoryId?: number, excludeId?: string): void {
        if (!categoryId) return;
        this.isLoadingSimilar.set(true);
        this.itemsClient.getItems(1, 8, categoryId).pipe(
            tap((res) => {
                const items: ItemListDto[] = res?.data ?? [];
                this.similarItems.set(items.filter((it) => it.id !== excludeId).slice(0, 6));
            }),
            catchError(() => of(null)),
            finalize(() => { this.isLoadingSimilar.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    setActiveImage(index: number): void { this.activeImageIndex.set(index); }

    addToFavorites(): void {
        const id = this.item()?.id;
        if (!id) return;
        this.isFavoriting.set(true);
        this.favoritesClient.addFavorite(id).pipe(
            tap(() => this.showToast('items.addedToFavorites')),
            catchError(() => { this.showToast('common.errorOccurred'); return of(null); }),
            finalize(() => { this.isFavoriting.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    checkReminderStatus(id: string): void {
        this.itemsClient.getItemReminderStatus(id).pipe(
            tap((res) => {
                if (res?.data) this.isReminded.set(res.data.isReminded || false);
            }),
            catchError(() => of(null)),
            finalize(() => this.cdr.markForCheck())
        ).subscribe();
    }

    toggleReminder(): void {
        const id = this.item()?.id;
        if (!id) return;
        
        const action = this.isReminded() 
            ? this.itemsClient.removeItemReminder(id) 
            : this.itemsClient.addItemReminder(id);
            
        action.pipe(
            tap((res) => {
                if (!res?.error) {
                    this.isReminded.set(!this.isReminded());
                    this.showToast(this.isReminded() ? 'marketplace.reminderAdded' : 'marketplace.reminderRemoved');
                }
            }),
            catchError(() => { this.showToast('common.errorOccurred'); return of(null); }),
            finalize(() => this.cdr.markForCheck())
        ).subscribe();
    }

    rentItem(): void {
        const item = this.item();
        if (!item?.id) return;
        this.router.navigate(['/rentals', 'new'], { queryParams: { itemId: item.id } });
    }

    buyItem(): void {
        const item = this.item();
        if (!item?.id) return;
        // For now, redirect to chat to negotiate or a simple buy-now flow
        this.startChat();
        this.showToast('items.buyRequestSent');
    }
    
    dateFilter = (d: Date | null): boolean => {
        if (!d) return false;
        const time = d.getTime();
        // Check if d is within any booked range
        return !this.bookedDates().some(range => {
            if (!range.start || !range.end) return false;
            const start = new Date(range.start).getTime();
            const end = new Date(range.end).getTime();
            return time >= start && time <= end;
        });
    };

    startChat(): void {
        const ownerId = this.item()?.owner?.id;
        if (!ownerId) return;
        this.isChatting.set(true);
        
        const cmd = new CreateChatCommand({
            userId: ownerId,
            itemId: this.item()?.id as any
        });

        this.chatClient.createChat(cmd).pipe(
            tap((res: any) => {
                const chatId = res?.data?.chatId || (res?.data as any)?.id;
                if (chatId) this.router.navigate(['/chats', chatId]);
                else this.router.navigate(['/chats']);
            }),
            catchError(() => { this.showToast('common.errorOccurred'); return of(null); }),
            finalize(() => { this.isChatting.set(false); this.cdr.markForCheck(); })
        ).subscribe();
    }

    setHoveredStar(star: number): void { this.hoveredStar.set(star); }
    clearHoveredStar(): void { this.hoveredStar.set(0); }
    selectStar(star: number): void { this.selectedStar.set(star); }

    submitReview(): void {
        const itemId = this.item()?.id;
        if (this.reviewForm.invalid || !this.selectedStar() || !itemId) return;

        this.isSubmittingReview.set(true);
        const cmd = new CreateReviewCommand({
            rentalId: itemId, // In the current backend, we handle mapping itemId to a valid rental context if found
            rating: this.selectedStar(),
            comment: this.reviewForm.value.comment,
        });

        this.reviewsClient.createReview(itemId, cmd).pipe(
            tap((res) => {
                if (!res?.error) {
                    this.showToast('items.reviewSubmitted');
                    this.reviewForm.reset();
                    this.selectedStar.set(0);
                    this.loadReviews(itemId);
                } else {
                    this.showToast('items.reviewRequiresRental');
                }
            }),
            catchError(() => { 
                this.showToast('items.reviewRequiresRental'); 
                return of(null); 
            }),
            finalize(() => { 
                this.isSubmittingReview.set(false); 
                this.cdr.markForCheck(); 
            })
        ).subscribe();
    }

    private showToast(key: string): void {
        this.toast.showSuccess(key);
    }
}
