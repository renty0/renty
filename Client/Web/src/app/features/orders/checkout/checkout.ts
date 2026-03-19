import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ItemsClient, ItemDetailDto, OrdersClient, CreateOrderCommand, ApiResponse, OrderCreateData, OrderItemInputDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    MatProgressSpinnerModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './checkout.html',
  styleUrl: './checkout.scss'
})
export class CheckoutComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private itemsClient = inject(ItemsClient);
  private ordersClient = inject(OrdersClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  itemId = signal('');
  item = signal<ItemDetailDto | null>(null);
  isLoading = signal(true);
  isPlacingOrder = signal(false);

  deliveryFee = 50; // Mocked delivery fee

  subtotal = computed(() => {
    const item = this.item();
    if (!item) return 0;
    return item.pricing?.find((p: any) => p.pricingType === 'Daily')?.price ?? 
           item.pricing?.[0]?.price ?? 0;
  });

  total = computed(() => this.subtotal() + this.deliveryFee);

  ngOnInit() {
    this.itemId.set(this.route.snapshot.paramMap.get('id') || '');
    if (this.itemId()) {
      this.loadItem();
    }
  }

  loadItem() {
    this.isLoading.set(true);
    this.itemsClient.getItemById(this.itemId())
      .pipe(
        tap((res: ApiResponse<ItemDetailDto>) => {
          if (res.data) {
            this.item.set(res.data);
          }
        }),
        catchError((err: any) => {
          this.toast.showError('errors.failedToLoadProduct');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }

  placeOrder() {
    if (!this.item()) return;

    this.isPlacingOrder.set(true);
    const command = new CreateOrderCommand({
      items: [
        new OrderItemInputDto({ itemId: this.itemId(), quantity: 1 })
      ]
    });

    this.ordersClient.createOrder(command)
      .pipe(
        tap((res: ApiResponse<OrderCreateData>) => {
          if (!res.error) {
            this.toast.showSuccess('checkout.success');
            this.router.navigate(['/checkout', res.data?.orderId, 'payment']);
          } else {
            const errorMsg = res.messages && res.messages.length > 0 ? res.messages[0] : 'checkout.error';
            this.toast.showError(errorMsg);
          }
        }),
        catchError((err: any) => {
          this.toast.showError('checkout.error');
          return of(null);
        }),
        finalize(() => this.isPlacingOrder.set(false))
      ).subscribe();
  }

  getLocalizedName(item: any): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (item.titleAr || item.titleEn || '') : (item.titleEn || item.titleAr || '');
  }
}
