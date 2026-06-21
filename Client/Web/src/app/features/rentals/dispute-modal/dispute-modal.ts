import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { MultiImageUploaderComponent, UploadedImage } from '../../../shared/components/multi-image-uploader/multi-image-uploader.component';
import { InputComponent } from '../../../shared/components/input/input';
import { RentalsClient, OpenDisputeBody } from '../../../core/api/api-client';

@Component({
  selector: 'app-dispute-modal',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatIconModule,
    TranslateModule,
    LoadingButtonComponent,
    MultiImageUploaderComponent,
    InputComponent
  ],
  templateUrl: './dispute-modal.html',
  styleUrl: './dispute-modal.scss'
})
export class DisputeModalComponent {
  private fb = inject(FormBuilder);
  private toast = inject(ToastService);
  private dialogRef = inject(MatDialogRef<DisputeModalComponent>);
  private rentalsClient = inject(RentalsClient);
  public data = inject<{ rentalId: string }>(MAT_DIALOG_DATA);

  disputeForm: FormGroup;
  isSubmitting = signal(false);
  uploadedPhotos = signal<UploadedImage[]>([]);

  disputeReasonOptions = [
    { name: 'rentals.disputes.reasons.broken', code: 'rentals.disputes.reasons.broken' },
    { name: 'rentals.disputes.reasons.not_as_described', code: 'rentals.disputes.reasons.not_as_described' },
    { name: 'rentals.disputes.reasons.late_return', code: 'rentals.disputes.reasons.late_return' },
    { name: 'rentals.disputes.reasons.other', code: 'rentals.disputes.reasons.other' }
  ];

  constructor() {
    this.disputeForm = this.fb.group({
      reasonType: ['', Validators.required],
      description: ['', [Validators.required, Validators.minLength(10)]]
    });
  }

  onSubmit() {
    if (this.disputeForm.invalid) return;

    this.isSubmitting.set(true);

    const body = new OpenDisputeBody({
      reasonType: this.disputeForm.value.reasonType,
      description: this.disputeForm.value.description
    });

    this.rentalsClient.openRentalDispute(this.data.rentalId, body).subscribe({
      next: () => {
        this.toast.showSuccess('rentals.disputes.success');
        this.isSubmitting.set(false);
        this.dialogRef.close(true);
      },
      error: (err) => {
        this.toast.showError('rentals.disputes.error');
        console.error(err);
        this.isSubmitting.set(false);
      }
    });
  }

  onCancel() {
    this.dialogRef.close(false);
  }
}
