import { Component, Inject, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { TranslateModule } from '@ngx-translate/core';
import { IdentityClient, ReviewIdVerificationCommand, AdminIdVerificationDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent, SelectOption } from '../../../../shared/components/input/input';
import { finalize } from 'rxjs';

@Component({
  selector: 'app-review-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatIconModule,
    TranslateModule,
    InputComponent,
    LoadingButtonComponent
  ],
  templateUrl: './review-dialog.component.html',
  styleUrl: './review-dialog.component.scss'
})
export class ReviewDialogComponent {
  private fb = inject(FormBuilder);
  private identityClient = inject(IdentityClient);
  private toast = inject(ToastService);
  dialogRef = inject(MatDialogRef<ReviewDialogComponent>);

  loading = signal(false);
  reviewForm: FormGroup;

  statusOptions: SelectOption[] = [
    { name: 'adminIdVerification.approved', code: 'approved' },
    { name: 'adminIdVerification.rejected', code: 'rejected' }
  ];

  // Track active preview image for zoom
  selectedZoomImage = signal<string | null>(null);

  constructor(@Inject(MAT_DIALOG_DATA) public data: { request: AdminIdVerificationDto }) {
    this.reviewForm = this.fb.group({
      status: ['', Validators.required],
      rejectionReason: ['']
    });

    // Handle rejection reason validation dynamically based on status selection
    this.reviewForm.get('status')?.valueChanges.subscribe(status => {
      const reasonControl = this.reviewForm.get('rejectionReason');
      if (status === 'rejected') {
        reasonControl?.setValidators([Validators.required]);
      } else {
        reasonControl?.clearValidators();
      }
      reasonControl?.updateValueAndValidity();
    });
  }

  submitVerdict() {
    if (this.reviewForm.invalid || !this.data.request.id) return;

    this.loading.set(true);
    const formVal = this.reviewForm.value;

    const command = new ReviewIdVerificationCommand({
      idVerificationId: this.data.request.id,
      status: formVal.status,
      rejectionReason: formVal.status === 'rejected' ? formVal.rejectionReason : null
    });

    this.identityClient.reviewIdVerification(this.data.request.id, command)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error) {
            const successMsgKey = formVal.status === 'approved' 
              ? 'adminIdVerification.successApprove' 
              : 'adminIdVerification.successReject';
            this.toast.showSuccess(successMsgKey);
            this.dialogRef.close(true);
          } else {
            this.toast.showError(res.messages?.[0] || 'adminIdVerification.errorUpdate');
          }
        },
        error: (err) => {
          this.toast.showError('adminIdVerification.errorUpdate');
        }
      });
  }

  zoomImage(imgUrl: string | undefined) {
    if (imgUrl) {
      this.selectedZoomImage.set(imgUrl);
    }
  }

  closeZoom() {
    this.selectedZoomImage.set(null);
  }
}
