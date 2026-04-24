import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { FormsModule } from '@angular/forms';
import {
  PaymentsClient,
  CreatePaymentCommand,
  ApiResponse,
  PaymentCreateData,
  OrdersClient,
  OrderDetailDto
} from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { catchError, finalize, of, tap } from 'rxjs';

export interface PaymentMethodConfig {
  id: string;
  icon: string;
  color: string;
  steps: string[];
  accountNumber?: string;
}

@Component({
  selector: 'app-payment',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    FormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
    MatDividerModule,
    MatProgressSpinnerModule,
    LoadingButtonComponent
  ],
  templateUrl: './payment.html',
  styleUrl: './payment.scss'
})
export class PaymentComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private paymentsClient = inject(PaymentsClient);
  private ordersClient = inject(OrdersClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  orderId = signal('');
  order = signal<OrderDetailDto | null>(null);
  isLoadingOrder = signal(true);
  selectedMethod = signal('vodafone_cash');
  transactionRef = signal('');
  isProcessing = signal(false);

  orderItems = computed(() => this.order()?.items ?? []);
  orderTotal = computed(() => this.order()?.totalAmount ?? 0);
  deliveryFee = 25;
  grandTotal = computed(() => this.orderTotal() + this.deliveryFee);

  selectedTransactionRef = '';

  paymentMethods: PaymentMethodConfig[] = [
    {
      id: 'vodafone_cash',
      icon: 'account_balance_wallet',
      color: '#e53935',
      accountNumber: '01012345678',
      steps: ['payment.methods.vodafoneCashStep1', 'payment.methods.vodafoneCashStep2', 'payment.methods.vodafoneCashStep3']
    },
    {
      id: 'fawry',
      icon: 'payments',
      color: '#ff8f00',
      accountNumber: '123456789',
      steps: ['payment.methods.fawryStep1', 'payment.methods.fawryStep2', 'payment.methods.fawryStep3']
    },
    {
      id: 'paymob',
      icon: 'credit_card',
      color: '#0066ff',
      steps: ['payment.methods.paymobStep1', 'payment.methods.paymobStep2']
    },
    {
      id: 'credit_card',
      icon: 'payment',
      color: '#6c63ff',
      steps: ['payment.methods.creditCardStep1', 'payment.methods.creditCardStep2']
    },
    {
      id: 'bank_transfer',
      icon: 'account_balance',
      color: '#00897b',
      accountNumber: 'EG123456789012345678901',
      steps: ['payment.methods.bankTransferStep1', 'payment.methods.bankTransferStep2', 'payment.methods.bankTransferStep3']
    }
  ];

  get selectedMethodConfig(): PaymentMethodConfig {
    return this.paymentMethods.find(m => m.id === this.selectedMethod()) ?? this.paymentMethods[0];
  }

  ngOnInit() {
    this.orderId.set(this.route.snapshot.paramMap.get('id') || '');
    if (this.orderId()) {
      this.loadOrder();
    } else {
      this.isLoadingOrder.set(false);
    }
  }

  private loadOrder() {
    this.ordersClient.getOrderById(this.orderId())
      .pipe(
        tap((res: ApiResponse<OrderDetailDto>) => {
          if (!res.error && res.data) {
            this.order.set(res.data);
          }
        }),
        catchError(() => of(null)),
        finalize(() => this.isLoadingOrder.set(false))
      ).subscribe();
  }

  selectMethod(methodId: string) {
    this.selectedMethod.set(methodId);
  }

  processPayment() {
    if (!this.orderId()) return;

    this.isProcessing.set(true);
    const command = new CreatePaymentCommand({
      orderId: this.orderId(),
      method: this.selectedMethod(),
      transactionRef: this.selectedTransactionRef || undefined
    } as any);

    this.paymentsClient.createPayment(command)
      .pipe(
        tap((res: ApiResponse<PaymentCreateData>) => {
          if (!res.error) {
            this.toast.showSuccess('payment.success');
            this.router.navigate(['/orders', this.orderId()]);
          } else {
            const errorMsg = res.messages && res.messages.length > 0 ? res.messages[0] : 'payment.error';
            this.toast.showError(errorMsg);
          }
        }),
        catchError(() => {
          this.toast.showError('payment.error');
          return of(null);
        }),
        finalize(() => this.isProcessing.set(false))
      ).subscribe();
  }
}
