import { Component, inject, signal, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { AuthService } from '../../../../core/services/auth.service';
import { finalize } from 'rxjs';
import { emailValidator } from '../../../../validators/email.validator';

import { AuthClient, SendEmailConfirmationCommand } from '../../../../core/api/api-client';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-verify-email',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    TranslatePipe,
    InputComponent,
    LoadingButtonComponent,
    MatIconModule,
  ],
  templateUrl: './verify-email.component.html',
  styleUrl: './verify-email.component.scss',
})
export class VerifyEmailComponent implements OnInit, OnDestroy {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private toast = inject(ToastService);
  private translate = inject(TranslateService);
  private authClient = inject(AuthClient);

  loading = signal(false);
  verified = signal(false);
  codeSent = signal(false);

  countdown = signal(0);
  private resendInterval: any;

  verifyForm = this.fb.group({
    email: ['', [Validators.required, emailValidator()]],
    code: ['', [Validators.required, Validators.minLength(1)]],
  });

  ngOnInit() {
    const email = this.route.snapshot.queryParamMap.get('email');
    const code = this.route.snapshot.queryParamMap.get('code');
    if (email) {
      this.codeSent.set(true);
      this.verifyForm.patchValue({ email });
      this.startResendTimer();
    }
    if (email && code) {
      this.verifyForm.patchValue({ code });
      this.submit();
    }
  }

  ngOnDestroy() {
    if (this.resendInterval) {
      clearInterval(this.resendInterval);
    }
  }

  startResendTimer() {
    this.countdown.set(30);
    if (this.resendInterval) {
      clearInterval(this.resendInterval);
    }
    this.resendInterval = setInterval(() => {
      if (this.countdown() > 0) {
        this.countdown.update((c) => c - 1);
      } else {
        clearInterval(this.resendInterval);
      }
    }, 1000);
  }

  resendCode() {
    if (this.countdown() > 0 && this.codeSent()) return;

    const email = this.verifyForm.value.email;
    if (!email) {
      this.verifyForm.get('email')?.markAsTouched();
      return;
    }

    this.loading.set(true);
    const command = new SendEmailConfirmationCommand({ email });
    this.authClient
      .authSendVerification(command)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response) => {
          if (!response.error) {
            this.codeSent.set(true);
            this.toast.showSuccess(this.translate.instant('common.success'));
            this.startResendTimer();
          } else {
            this.toast.showError(response.messages?.[0] || this.translate.instant('common.error'));
          }
        },
        error: () => {
          this.toast.showError(this.translate.instant('common.error'));
        },
      });
  }

  submit() {
    if (this.verifyForm.invalid) {
      this.verifyForm.markAllAsTouched();
      return;
    }

    const email = this.verifyForm.value.email!;
    const code = this.verifyForm.value.code!;

    this.loading.set(true);
    this.authService
      .verifyEmail(email, code)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response) => {
          if (!response.error) {
            this.verified.set(true);
            this.toast.showSuccess(this.translate.instant('verifyEmail.success'));
            setTimeout(() => this.router.navigate(['/login']), 1500);
          } else {
            this.toast.showError(
              response.messages?.[0] || this.translate.instant('verifyEmail.failed')
            );
          }
        },
        error: (error: { error?: { messages?: string[] } }) => {
          this.toast.showError(
            error?.error?.messages?.[0] ?? this.translate.instant('verifyEmail.failed')
          );
        },
      });
  }
}
