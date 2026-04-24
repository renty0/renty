import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { OrdersClient, OrderDetailDto, PaymentsClient, PaymentDto, DeliveryClient, TrackingEntryDto, ApiResponse } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { forkJoin, catchError, finalize, of, tap } from 'rxjs';

@Component({
  selector: 'app-order-details',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './order-details.html',
  styleUrl: './order-details.scss'
})
export class OrderDetailsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private ordersClient = inject(OrdersClient);
  private paymentsClient = inject(PaymentsClient);
  private deliveryClient = inject(DeliveryClient);
  public translate = inject(TranslateService);

  orderId = signal('');
  order = signal<OrderDetailDto | null>(null);
  payment = signal<PaymentDto | null>(null);
  deliveryTracking = signal<TrackingEntryDto[]>([]);
  isLoading = signal(true);

  ngOnInit() {
    this.route.params.subscribe(params => {
      this.orderId.set(params['id'] || '');
      if (this.orderId()) {
        this.loadAllData();
      }
    });
  }

  loadAllData() {
    this.isLoading.set(true);
    
    forkJoin({
      order: this.ordersClient.getOrderById(this.orderId()),
      payment: this.paymentsClient.getPaymentByOrder(this.orderId()).pipe(catchError(() => of({ data: null } as any))),
      delivery: this.deliveryClient.getDelivery(this.orderId()).pipe(catchError(() => of({ data: [] } as any)))
    }).pipe(
      tap((res: any) => {
        if (res.order.data) this.order.set(res.order.data);
        if (res.payment.data) this.payment.set(res.payment.data);
        if (res.delivery.data) this.deliveryTracking.set(res.delivery.data);
      }),
      finalize(() => this.isLoading.set(false))
    ).subscribe();
  }

  getStatusColor(status: string | undefined): string {
    if (!status) return 'default';
    switch (status.toLowerCase()) {
      case 'pending': return 'warning';
      case 'paid':
      case 'delivered':
      case 'success': return 'success';
      case 'shipped':
      case 'processing': return 'info';
      case 'cancelled':
      case 'failed': return 'error';
      default: return 'default';
    }
  }

  getLocalizedName(item: any): string {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? (item.titleAr || item.titleEn || '') : (item.titleEn || item.titleAr || '');
  }
}
