import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { WalletClient, RequestWithdrawalCommand } from '../../../core/api/api-client';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { TranslatePipe } from '@ngx-translate/core';

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
  imports: [CommonModule, FormsModule, MatIconModule, MatProgressSpinnerModule, TranslatePipe],
  templateUrl: './wallet-dashboard.component.html',
  styleUrl: './wallet-dashboard.component.scss'
})
export class WalletDashboardComponent implements OnInit {
  private walletClient = inject(WalletClient);

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
    this.walletClient.getWalletBalance().subscribe({
      next: (res) => this.balance.set((res.data as any)?.balance || 0),
      error: (err) => console.error('Failed to load balance', err)
    });
  }

  fetchTransactions() {
    this.isLoading.set(true);
    this.walletClient.getWalletTransactions().subscribe({
      next: (res) => {
        this.transactions.set((res.data as any)?.transactions || []);
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

    const cmd = new RequestWithdrawalCommand({
      amount: this.withdrawAmount() ?? 0,
      mobileWalletNumber: this.mobileWalletNumber()
    });

    this.walletClient.requestWithdrawal(cmd).subscribe({
      next: () => {
        this.successMsg.set('Withdrawal requested successfully.');
        this.isSubmitting.set(false);
        this.fetchBalance();
        this.fetchTransactions();
        setTimeout(() => this.closeWithdraw(), 2000);
      },
      error: (err) => {
        this.errorMsg.set(err.response?.title || err.response?.detail || 'Failed to submit withdrawal request.');
        this.isSubmitting.set(false);
      }
    });
  }
}
