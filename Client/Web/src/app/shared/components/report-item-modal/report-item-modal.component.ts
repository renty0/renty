import { Component, EventEmitter, inject, Input, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-report-item-modal',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './report-item-modal.component.html',
  styleUrls: ['./report-item-modal.component.scss']
})
export class ReportItemModalComponent {
  @Input() itemId!: string;
  @Input() itemTitle!: string;
  @Output() close = new EventEmitter<void>();

  private http = inject(HttpClient);

  reason = signal<string>('');
  notes = signal<string>('');
  isSubmitting = signal(false);
  successMsg = signal<string | null>(null);
  errorMsg = signal<string | null>(null);

  reportItem() {
    this.isSubmitting.set(true);
    this.errorMsg.set(null);
    
    // In actual implementation, we might have a specific endpoint or use support tickets
    const supportPayload = {
      type: 'report_item',
      subject: `Report Item: ${this.itemTitle} (${this.itemId})`,
      message: `Reason: ${this.reason()}\nNotes: ${this.notes()}\nItem ID: ${this.itemId}`
    };

    this.http.post('/api/v1/support/tickets', supportPayload).subscribe({
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
