import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DisputesClient, ResolveDisputeCommand } from '../../../core/api/api-client';
import { MatIconModule } from '@angular/material/icon';


@Component({
  selector: 'app-agent-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, MatIconModule],
  templateUrl: './agent-dashboard.component.html',
  styleUrl: './agent-dashboard.component.scss'
})
export class AgentDashboardComponent {
  private disputesClient = inject(DisputesClient);

  rentalId = signal<string>('');
  reason = signal<string>('');
  resolutionType = signal<'forfeit_deposit' | 'refund_renter' | 'split_deposit'>('split_deposit');
  
  ownerCompensation = signal<number>(0);
  renterRefund = signal<number>(0);

  isLoading = signal(false);
  successMsg = signal<string | null>(null);
  errorMsg = signal<string | null>(null);

  resolveDispute() {
    this.isLoading.set(true);
    this.errorMsg.set(null);
    this.successMsg.set(null);

    const cmd = new ResolveDisputeCommand({
      rentalId: this.rentalId(),
      resolutionDecision: this.resolutionType(),
      ownerCompensation: this.ownerCompensation(),
      renterRefund: this.renterRefund(),
      reason: this.reason()
    });

    this.disputesClient.resolveDispute(cmd).subscribe({
      next: () => {
        this.successMsg.set('Dispute resolved successfully. Wallets updated.');
        this.isLoading.set(false);
        this.resetForm();
      },
      error: (err) => {
        this.errorMsg.set(err.response?.title || err.response?.detail || 'Failed to resolve dispute.');
        this.isLoading.set(false);
      }
    });
  }

  resetForm() {
    this.rentalId.set('');
    this.reason.set('');
    this.ownerCompensation.set(0);
    this.renterRefund.set(0);
  }
}
