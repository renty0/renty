import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from '../../../../shared/services/toast.service';

import { IdentityClient, UploadIdVerificationCommand } from '../../../../core/api/api-client';
import { finalize, catchError, of } from 'rxjs';

@Component({
  selector: 'app-id-verification',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './id-verification.component.html',
  styleUrl: '../login/login.scss'
})
export class IdVerificationComponent {
  private identityClient = inject(IdentityClient);
  private router = inject(Router);
  private toast = inject(ToastService);

  frontImage = signal<string | null>(null);
  backImage = signal<string | null>(null);
  
  isLoading = signal(false);
  successMsg = signal<string | null>(null);
  errorMsg = signal<string | null>(null);

  onFileSelected(event: any, side: 'front' | 'back') {
    const file = event.target.files[0];
    if (file) {
      const fakeUrl = URL.createObjectURL(file);
      if (side === 'front') this.frontImage.set(fakeUrl);
      if (side === 'back') this.backImage.set(fakeUrl);
    }
  }

  submitDocument() {
    this.isLoading.set(true);

    const command = new UploadIdVerificationCommand({
      frontImageUrl: this.frontImage() || 'simulate-s3-front.jpg',
      backImageUrl: this.backImage() || 'simulate-s3-back.jpg'
    });

    this.identityClient.uploadIdVerification(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError(() => {
          this.toast.showError('Failed to submit ID.');
          return of(null);
        })
      )
      .subscribe((res) => {
        if (res && res.error) {
          this.toast.showError(res.messages?.[0] || 'Failed to submit ID.');
        } else if (res) {
          this.successMsg.set('ID Verification submitted! Waiting for Admin approval.');
          this.toast.showSuccess('ID Verification submitted!');
          setTimeout(() => this.router.navigate(['/items']), 3000);
        }
      });
  }
}
