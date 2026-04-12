import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule, DatePipe, CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

export interface WalletTransaction {
  id: string;
  amount: number;
  type: string;
  description: string;
  createdAt: string;
}

@Component({
  selector: 'app-wallet-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, DatePipe, CurrencyPipe],
  templateUrl: './wallet-dashboard.component.html',
  styleUrls: ['./wallet-dashboard.component.scss']
})
export class WalletDashboardComponent implements OnInit {
  private http = inject(HttpClient);

  balance = signal<number>(0);
  transactions = signal<WalletTransaction[]>([]);
  
  // Withdrawal Modal State
  showWithdrawForm = signal(false);
  withdrawAmount = signal<number | null>(null);
  mobileWalletNumber = signal<string>('');
  
  isLoading = signal(false);
  isSubmitting = signal(false);
  errorMsg = signal<string | null>(null);
  successMsg = signal<string | null>(null);

  ngOnInit(): void {
    this.fetchBalance();
    this.fetchTransactions();
  }

  fetchBalance() {
    this.http.get<{ balance: number }>('/api/v1/wallet/balance').subscribe({
      next: (res) => this.balance.set(res.balance),
      error: (err) => console.error('Failed to load balance', err)
    });
  }

  fetchTransactions() {
    this.isLoading.set(true);
    this.http.get<WalletTransaction[]>('/api/v1/wallet/transactions').subscribe({
      next: (res) => {
        this.transactions.set(res);
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load transactions', err);
        this.isLoading.set(false);
      }
    });
  }

  openWithdraw() {
    this.showWithdrawForm.set(true);
    this.errorMsg.set(null);
    this.successMsg.set(null);
  }

  closeWithdraw() {
    this.showWithdrawForm.set(false);
    this.withdrawAmount.set(null);
    this.mobileWalletNumber.set('');
  }

  requestWithdrawal() {
    this.errorMsg.set(null);
    this.isSubmitting.set(true);

    const payload = {
      amount: this.withdrawAmount(),
      mobileWalletNumber: this.mobileWalletNumber()
    };

    this.http.post('/api/v1/wallet/withdraw', payload).subscribe({
      next: () => {
        this.successMsg.set('Withdrawal requested successfully.');
        this.isSubmitting.set(false);
        this.fetchBalance();
        this.fetchTransactions();
        setTimeout(() => this.closeWithdraw(), 2000);
      },
      error: (err) => {
        this.errorMsg.set(err.error?.title || err.error?.detail || 'Failed to submit withdrawal request.');
        this.isSubmitting.set(false);
      }
    });
  }
}
