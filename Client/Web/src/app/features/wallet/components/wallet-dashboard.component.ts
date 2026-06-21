import { Component, inject, signal, OnInit, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { WalletClient, RequestWithdrawalCommand } from '../../../core/api/api-client';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

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
  imports: [CommonModule, FormsModule, MatIconModule, MatProgressSpinnerModule, TranslateModule],
  templateUrl: './wallet-dashboard.component.html',
  styleUrl: './wallet-dashboard.component.scss'
})
export class WalletDashboardComponent implements OnInit {
  private walletClient = inject(WalletClient);
  private translate = inject(TranslateService);

  balance = signal<number>(0);
  pendingBalance = signal<number>(0);
  transactions = signal<WalletTransaction[]>([]);
  
  totalEarnings = computed(() => {
    return this.transactions()
      .filter(t => t.amount > 0 && t.type === 'Adjustment')
      .reduce((sum, t) => sum + t.amount, 0);
  });

  totalBalance = computed(() => this.balance() + this.pendingBalance());
  withdrawableBalance = computed(() => this.balance());

  // Withdrawal Modal State
  showWithdrawForm = signal(false);
  withdrawAmount = signal<number | null>(null);
  mobileWalletNumber = signal<string>('');
  
  isLoading = signal(false);
  isSubmitting = signal(false);
  errorMsg = signal<string | null>(null);
  successMsg = signal<string | null>(null);

  // Top Up Modal State
  showTopUpForm = signal(false);
  topUpAmount = signal<number | null>(null);

  ngOnInit(): void {
    this.fetchBalance();
    this.fetchTransactions();
  }

  fetchBalance() {
    this.walletClient.getWalletBalance().subscribe({
      next: (res) => {
        this.balance.set((res.data as any)?.balance || 0);
        this.pendingBalance.set((res.data as any)?.pendingBalance || 0);
      },
      error: (err) => console.error('Failed to load balance', err)
    });
  }

  fetchTransactions() {
    this.isLoading.set(true);
    this.walletClient.getWalletTransactions().subscribe({
      next: (res) => {
        const txs = (res.data as any)?.transactions || [];
        this.transactions.set(txs.slice(0, 100));
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

  openTopUp() {
    this.showTopUpForm.set(true);
    this.errorMsg.set(null);
    this.successMsg.set(null);
  }

  closeTopUp() {
    this.showTopUpForm.set(false);
    this.topUpAmount.set(null);
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
        this.successMsg.set(this.translate.instant('wallet.success_message'));
        this.isSubmitting.set(false);
        this.fetchBalance();
        this.fetchTransactions();
        setTimeout(() => this.closeWithdraw(), 2000);
      },
      error: (err) => {
        const msg = err.response?.title || err.response?.detail || this.translate.instant('wallet.error_message');
        this.errorMsg.set(msg);
        this.isSubmitting.set(false);
      }
    });
  }

  requestTopUp() {
    this.errorMsg.set(null);
    this.isSubmitting.set(true);

    this.walletClient.topUpWallet({ amount: this.topUpAmount() ?? 0 }).subscribe({
      next: () => {
        this.successMsg.set(this.translate.instant('wallet.top_up_success'));
        this.isSubmitting.set(false);
        this.fetchBalance();
        this.fetchTransactions();
        setTimeout(() => this.closeTopUp(), 2000);
      },
      error: (err) => {
        const msg = err.response?.title || err.response?.detail || this.translate.instant('wallet.top_up_error');
        this.errorMsg.set(msg);
        this.isSubmitting.set(false);
      }
    });
  }

  private typeCache = new Map<string, string>();
  private descCache = new Map<string, string>();

  getLocalizedType(type: string): string {
    const lang = this.translate.currentLang || this.translate.defaultLang || 'en';
    const key = type + '_' + lang;
    if (this.typeCache.has(key)) return this.typeCache.get(key)!;

    const typeMap: Record<string, string> = {
      'Adjustment': 'wallet.tx_type.adjustment',
      'Withdrawal': 'wallet.tx_type.withdrawal',
      'EscrowHold': 'wallet.tx_type.escrow_hold',
      'EscrowRelease': 'wallet.tx_type.escrow_release',
      'Penalty': 'wallet.tx_type.penalty',
      'PendingEarnings': 'wallet.tx_type.pending_earnings',
      'RentalEarnings': 'wallet.tx_type.rental_earnings',
      'RentalIncome': 'wallet.tx_type.rental_income',
      'Refund': 'wallet.tx_type.refund',
    };

    const translationKey = typeMap[type];
    const res = translationKey ? (this.translate.instant(translationKey) || type) : type;

    this.typeCache.set(key, res);
    return res;
  }

  getLocalizedDescription(t: WalletTransaction): string {
    const lang = this.translate.currentLang || this.translate.defaultLang || 'en';
    const key = t.id + '_' + lang;
    if (this.descCache.has(key)) return this.descCache.get(key)!;

    let res = t.description;
    const desc = t.description || '';

    // Wallet Top-Up (Simulation)
    if (desc === 'Wallet Top-Up (Simulation)') {
      res = this.translate.instant('wallet.tx_desc.top_up');

    // Withdrawal requested to <number>
    } else if (desc.startsWith('Withdrawal requested to')) {
      const number = desc.replace('Withdrawal requested to ', '');
      res = this.translate.instant('wallet.tx_desc.withdrawal') + ' ' + number;

    // Pending rental income for '<item>' (Rental ID: <id>)
    // Pending rental income (clears in 14 days) for '<item>'
    } else if (desc.startsWith('Pending rental income')) {
      const match = desc.match(/for '(.*?)'/);
      const item = match ? match[1] : '';
      res = this.translate.instant('wallet.tx_desc.pending_rental_income', { item });

    // Pending extra income (Late fee/Penalty) for '<item>' (Rental ID: <id>)
    } else if (desc.startsWith('Pending extra income')) {
      const match = desc.match(/for '(.*?)'/);
      const item = match ? match[1] : '';
      res = this.translate.instant('wallet.tx_desc.pending_extra_income', { item });

    // Late fee for '<item>' (Rental ID: <id>)
    } else if (desc.startsWith('Late fee for')) {
      const match = desc.match(/for '(.*?)'/);
      const item = match ? match[1] : '';
      res = this.translate.instant('wallet.tx_desc.late_fee', { item });

    // Deposit returned for rental <id>
    } else if (desc.startsWith('Deposit returned')) {
      res = this.translate.instant('wallet.tx_desc.deposit_returned');

    // Deposit refund for cancelled rental <id>
    } else if (desc.startsWith('Deposit refund')) {
      res = this.translate.instant('wallet.tx_desc.deposit_refund');

    // Rental refund for cancelled rental <id>
    } else if (desc.startsWith('Rental refund')) {
      res = this.translate.instant('wallet.tx_desc.rental_refund');

    // Escrow release for completed rental <id>
    } else if (desc.startsWith('Escrow release for completed')) {
      res = this.translate.instant('wallet.tx_desc.escrow_release_completed');

    // Escrow release for cancelled rental <id>
    } else if (desc.startsWith('Escrow release for cancelled')) {
      res = this.translate.instant('wallet.tx_desc.escrow_release');

    // Escrow hold for deposit on rental <id> / Escrow hold for order <id> / Escrow hold for rental order <id>
    } else if (t.type === 'EscrowHold' || desc.startsWith('Escrow hold for')) {
      res = this.translate.instant('wallet.tx_desc.escrow_hold');

    // Payment for rental <id>
    } else if (desc.startsWith('Payment for rental')) {
      res = this.translate.instant('wallet.tx_desc.rental_payment');

    // Reversal of pending income due to cancellation for '<item>' (Rental ID: <id>)
    } else if (desc.startsWith('Reversal of pending income')) {
      const match = desc.match(/for '(.*?)'/);
      const item = match ? match[1] : '';
      res = this.translate.instant('wallet.tx_desc.pending_income_reversal', { item });

    // Dispute Resolution: Compensation for rental <id> - <reason>
    } else if (desc.startsWith('Dispute Resolution: Compensation')) {
      res = this.translate.instant('wallet.tx_desc.dispute_compensation');

    // Dispute Resolution: Refund for rental <id> - <reason>
    } else if (desc.startsWith('Dispute Resolution: Refund')) {
      res = this.translate.instant('wallet.tx_desc.dispute_refund');

    // Cancellation fee (simple or with policy)
    } else if (desc.startsWith('Cancellation fee')) {
      const match = desc.match(/Cancellation fee \((.*?)\) for '(.*?)'/);
      if (match) {
        let policy = match[1];
        if (policy === 'Flexible policy' && lang === 'ar') policy = 'سياسة مرنة';
        else if (policy === 'Moderate policy' && lang === 'ar') policy = 'سياسة متوسطة';
        else if (policy === 'Strict policy' && lang === 'ar') policy = 'سياسة صارمة';
        const itemName = match[2];
        res = this.translate.instant('wallet.tx_desc.cancellation_fee', { policy, item: itemName });
      } else {
        res = this.translate.instant('wallet.tx_desc.cancellation_fee_generic');
      }
    }

    this.descCache.set(key, res);
    return res;
  }
}
