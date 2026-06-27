import { Component, inject, signal } from '@angular/core';

import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from '../../../../shared/services/toast.service';

import { IdentityClient, RequestPhoneVerificationCommand, ConfirmPhoneVerificationCommand } from '../../../../core/api/api-client';
import { finalize, catchError, of } from 'rxjs';

@Component({
  selector: 'app-phone-verification',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './phone-verification.component.html',
  styleUrl: '../login/login.scss'
})
export class PhoneVerificationComponent {
  private identityClient = inject(IdentityClient);
  private router = inject(Router);
  private toast = inject(ToastService);

  step = signal<1 | 2>(1);
  isLoading = signal(false);
  successMsg = signal<string | null>(null);
  errorMsg = signal<string | null>(null);

  phone = signal('');
  otp = signal('');

  requestVerification() {
    if (!this.phone() || this.isLoading()) {
      return;
    }

    this.isLoading.set(true);
    const command = new RequestPhoneVerificationCommand({ phoneNumber: this.phone() });

    this.identityClient.requestPhoneVerification(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError(() => {
          this.toast.showError('Failed to request OTP');
          return of(null);
        })
      )
      .subscribe((res) => {
        if (res && res.error) {
          this.toast.showError(res.messages?.[0] || 'Failed to request OTP');
        } else if (res) {
          this.step.set(2);
          this.successMsg.set(res.messages?.[0] || 'OTP Sent successfully!');
          this.toast.showSuccess('OTP Sent successfully!');
        }
      });
  }

  verifyOtp() {
    if (this.otp().length !== 4 || this.isLoading()) {
      return;
    }

    this.isLoading.set(true);
    const command = new ConfirmPhoneVerificationCommand({ code: this.otp() });

    this.identityClient.confirmPhoneVerification(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError(() => {
          this.toast.showError('Invalid OTP');
          return of(null);
        })
      )
      .subscribe((res) => {
        if (res && res.error) {
          this.toast.showError(res.messages?.[0] || 'Invalid OTP');
        } else if (res) {
          this.toast.showSuccess('Phone verified successfully!');
          setTimeout(() => this.router.navigate(['/profile']), 1500);
        }
      });
  }
}
