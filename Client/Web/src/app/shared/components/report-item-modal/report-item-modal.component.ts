import { Component, EventEmitter, inject, Input, Output, signal } from '@angular/core';

import { FormsModule } from '@angular/forms';
import { SupportClient, CreateTicketCommand } from '../../../core/api/api-client';

@Component({
  selector: 'app-report-item-modal',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './report-item-modal.component.html',
  styleUrls: ['./report-item-modal.component.scss']
})
export class ReportItemModalComponent {
  @Input() itemId!: string;
  @Input() itemTitle!: string;
  @Output() close = new EventEmitter<void>();

  private supportClient = inject(SupportClient);

  reason = signal<string>('');
  notes = signal<string>('');
  isSubmitting = signal(false);
  successMsg = signal<string | null>(null);
  errorMsg = signal<string | null>(null);

  reportItem() {
    this.isSubmitting.set(true);
    this.errorMsg.set(null);
    
    const cmd = new CreateTicketCommand({
      type: 'report_item',
      message: `Subject: Report Item: ${this.itemTitle} (${this.itemId})\nReason: ${this.reason()}\nNotes: ${this.notes()}\nItem ID: ${this.itemId}`
    });

    this.supportClient.createSupportTicket(cmd).subscribe({
      next: () => {
        this.successMsg.set('Item successfully reported to the support team.');
        this.isSubmitting.set(false);
        setTimeout(() => this.onClose(), 2500);
      },
      error: () => {
        this.errorMsg.set('Failed to submit report. Please try again.');
        this.isSubmitting.set(false);
      }
    });
  }

  onClose() {
    this.close.emit();
  }
}
