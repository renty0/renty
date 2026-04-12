import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-phone-verification',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './phone-verification.component.html',
  styleUrls: ['./phone-verification.component.scss']
})
export class PhoneVerificationComponent {
  private http = inject(HttpClient);
  private router = inject(Router);

  phone = signal('');
  otp = signal('');
  step = signal<1 | 2>(1); // 1: request, 2: verify
  isLoading = signal(false);
  errorMsg = signal<string | null>(null);
  successMsg = signal<string | null>(null);

  requestVerification() {
    this.isLoading.set(true);
    this.errorMsg.set(null);
    this.http.post<{ simulatedOtp: string }>('/api/v1/user/phone/request', { phoneNumber: this.phone() })
      .subscribe({
        next: (res) => {
          this.step.set(2);
          this.successMsg.set(`For simulation purposes, your OTP is: ${res.simulatedOtp}`);
          this.isLoading.set(false);
        },
        error: (err) => {
          this.errorMsg.set(err.error?.title || 'Failed to request OTP');
          this.isLoading.set(false);
        }
      });
  }

  verifyOtp() {
    this.isLoading.set(true);
    this.errorMsg.set(null);
    this.http.post('/api/v1/user/phone/confirm', { code: this.otp() })
      .subscribe({
        next: () => {
          this.successMsg.set('Phone verified successfully!');
          this.isLoading.set(false);
          setTimeout(() => this.router.navigate(['/items']), 1500);
        },
        error: (err) => {
          this.errorMsg.set(err.error?.title || 'Invalid OTP');
          this.isLoading.set(false);
        }
      });
  }
}
