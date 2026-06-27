import { Component, inject, signal } from '@angular/core';

import { FormsModule } from '@angular/forms';
import { DisputesClient, ResolveDisputeCommand } from '../../../core/api/api-client';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';


@Component({
  selector: 'app-agent-dashboard',
  standalone: true,
  imports: [
    FormsModule,
    MatIconModule,
    MatCardModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    TranslateModule,
    HeaderSectionComponent
],
  templateUrl: './agent-dashboard.component.html',
  styleUrl: './agent-dashboard.component.scss'
})
export class AgentDashboardComponent {
  private disputesClient = inject(DisputesClient);
  private translate = inject(TranslateService);

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
        this.successMsg.set(this.translate.instant('support.agent.resolveSuccess'));
        this.isLoading.set(false);
        this.resetForm();
      },
      error: (err) => {
        this.errorMsg.set(err.response?.title || err.response?.detail || this.translate.instant('support.agent.resolveFailed'));
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
