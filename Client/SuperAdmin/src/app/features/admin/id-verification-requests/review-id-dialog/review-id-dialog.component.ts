import { Component, Inject, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogRef, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { IdentityClient, IdVerificationRequestDto, ReviewIdVerificationCommand } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';
import { finalize } from 'rxjs';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';

import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'app-review-id-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
    FormsModule,
    LoadingButtonComponent,
    TranslateModule
  ],
  templateUrl: './review-id-dialog.component.html',
  styleUrl: './review-id-dialog.component.scss'
})
export class ReviewIdDialogComponent {
  private identityClient = inject(IdentityClient);
  private toastService = inject(ToastService);

  request: IdVerificationRequestDto;
  
  notes = '';
  submittingAction = signal<'approved' | 'rejected' | null>(null);

  constructor(
    public dialogRef: MatDialogRef<ReviewIdDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { request: IdVerificationRequestDto }
  ) {
    this.request = data.request;
  }

  approve() {
    this.submitReview('approved', this.notes);
  }

  reject() {
    if (!this.notes.trim()) {
      this.toastService.showError('idVerification.notesRequired');
      return;
    }
    this.submitReview('rejected', this.notes);
  }

  private submitReview(status: 'approved' | 'rejected', reason?: string) {
    this.submittingAction.set(status);
    
    const cmd = new ReviewIdVerificationCommand({
      idVerificationId: this.request.id,
      status: status,
      rejectionReason: reason
    });

    this.identityClient.reviewIdVerification(this.request.id!, cmd)
      .pipe(finalize(() => this.submittingAction.set(null)))
      .subscribe({
        next: () => {
          const successKey = status === 'approved' ? 'idVerification.approveSuccess' : 'idVerification.rejectSuccess';
          this.toastService.showSuccess(successKey);
          this.dialogRef.close(true); // Return true to signal the table to reload
        },
        error: (err) => {
          console.error('Failed to submit review', err);
          this.toastService.showError('idVerification.submitFailed');
        }
      });
  }
}
