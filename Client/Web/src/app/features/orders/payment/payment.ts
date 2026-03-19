import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatRadioModule } from '@angular/material/radio';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { PaymentsClient, CreatePaymentCommand, ApiResponse, PaymentCreateData } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { catchError, finalize, of, tap } from 'rxjs';

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
    MatRadioModule,
    MatFormFieldModule,
    MatInputModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './payment.html',
  styleUrl: './payment.scss'
})
export class PaymentComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private paymentsClient = inject(PaymentsClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  orderId = signal('');
  selectedMethod = signal('vodafone_cash');
  transactionRef = signal('');
  isProcessing = signal(false);

  paymentMethods = [
    { id: 'vodafone_cash', icon: 'account_balance_wallet' },
    { id: 'fawry', icon: 'payments' },
    { id: 'paymob', icon: 'credit_card' },
    { id: 'credit_card', icon: 'payment' },
    { id: 'bank_transfer', icon: 'account_balance' }
  ];

  ngOnInit() {
    this.orderId.set(this.route.snapshot.paramMap.get('id') || '');
  }

  processPayment() {
    if (!this.orderId()) return;

    this.isProcessing.set(true);
    const command = new CreatePaymentCommand({
      orderId: this.orderId(),
      method: this.selectedMethod(),
      transactionRef: this.transactionRef() || undefined
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
        catchError((err: any) => {
          this.toast.showError('payment.error');
          return of(null);
        }),
        finalize(() => this.isProcessing.set(false))
      ).subscribe();
  }
}
