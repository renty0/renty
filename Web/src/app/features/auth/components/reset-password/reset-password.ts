import { Component, inject, OnInit } from '@angular/core';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule, NgOptimizedImage } from '@angular/common';
// import { PasswordClient, ResetPasswordCommand, SendResetPasswordOTP, VerifyOTPCommand } from '../../../../../../api-client';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { CardModule } from 'primeng/card';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { TranslatePipe } from '@ngx-translate/core';
import { InputOtpModule } from 'primeng/inputotp';
import { emailValidator } from '../../../../validators/email.validator';
import { passwordMatchValidator } from '../../../../validators/password-match.validator';
import { passwordValidator } from '../../../../validators/password.validator';

@Component({
  selector: 'app-reset-password',
  imports: [ CommonModule, TranslatePipe, InputOtpModule, InputComponent, ReactiveFormsModule, RouterModule, NgOptimizedImage, ButtonModule, InputTextModule, CardModule, ProgressSpinnerModule],
  templateUrl: './reset-password.html',
  styleUrl: './reset-password.scss'
})
export class ResetPassword {
  private snackbar = inject(ToastService);
  private formBuilder = inject(FormBuilder);
  private route = inject(ActivatedRoute);
  // private passwordClient = inject(PasswordClient);
  private router = inject(Router);

  email: string | null = null;
  currentStep: 'email' | 'otp' | 'password' | 'success' = 'email';
  isLoading = false;
  isVerifying = false;
  isResetting = false;
  otp: string = '';

  resetPasswordForm = this.formBuilder.group({
    email: ['', [Validators.required, emailValidator()]],
    otp: ['', [Validators.required, Validators.minLength(6), Validators.maxLength(6)]],
    newPassword: ['', [Validators.required, passwordValidator()]],
    confirmPassword: ['', [Validators.required, passwordMatchValidator()]]
  }, {
    validators: passwordMatchValidator()
  });
  ngOnInit(): void {
    this.email = this.route.snapshot.queryParamMap.get('email');
    if (this.email) {
      this.resetPasswordForm.patchValue({ email: this.email });
      this.currentStep = 'email';
    }
  }
  passwordMatchValidator(form: any) {
    const newPassword = form.get('newPassword');
    const confirmPassword = form.get('confirmPassword');
    if (newPassword && confirmPassword && newPassword.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }
    return null;
  }
  sendResetPasswordOtp(): void {
    const emailControl = this.resetPasswordForm.get('email');
    if (!emailControl || emailControl.invalid || this.isLoading) return;
    // this.isLoading = true;
    this.snackbar.showInfo('OTP has been sent successfully.'); // to be removed
    this.currentStep = 'otp'; // to be removed
    // const request: SendResetPasswordOTP = new SendResetPasswordOTP({ email: emailControl.value! });
    // this.passwordClient.postApiPasswordSendResetPasswordOtp(request).subscribe({
    //   next: (response) => {
    //     this.isLoading = false;
    //     if (response.isSuccess) {
    //       this.email = emailControl.value!;
    //       this.currentStep = 'otp';
    //       this.snackbar.showSuccess('OTP has been sent successfully.');
    //     } else {
    //       this.showErrorMessage('Failed to send OTP. Please try again.');
    //     }
    //   },
    //   error: () => {
    //     this.isLoading = false;
    //     this.showErrorMessage('Network error. Please check your connection.');
    //   }
    // });
  }
  verifyOtpAndProceed(): void {
    const otpControl = this.resetPasswordForm.get('otp');
    if (!otpControl || otpControl.invalid || this.isVerifying) return;
    // this.isVerifying = true;
    this.snackbar.showInfo('OTP verified. Please set your new password.'); // to be removed
    this.currentStep = 'password'; // to be removed
    // this.passwordClient.postApiPasswordVerifyOTP(new VerifyOTPCommand({
    //   email: this.resetPasswordForm.value.email!,
    //   otp: this.resetPasswordForm.value.otp!
    // }).subscribe({
    //   next: (response) => {
    //     this.isVerifying = false;
    //     if (response.isSuccess) {
    //       this.currentStep = 'password';
    //       this.snackbar.showSuccess('OTP verified. Please set your new password.');
    //     } else {
    //       this.showErrorMessage('Invalid OTP. Please try again.');
    //       this.resetOtpInput();
    //     }
    //   },
    //   error: () => {
    //     this.isVerifying = false;
    //     this.showErrorMessage('Failed to verify OTP. Please try again.');
    //     this.resetOtpInput();
    //   }
    // });
  }
  resetPassword(): void {
    if (this.resetPasswordForm.invalid || this.isResetting) {
      this.resetPasswordForm.markAllAsTouched();
      return;
    }
    // this.isResetting = true;
    this.snackbar.showInfo('Password has been reset successfully.'); // to be removed
    this.currentStep = 'success'; // to be removed
    // this.passwordClient.patchApiPasswordResetPassword(new ResetPasswordCommand({
    //   email: this.resetPasswordForm.value.email!,
    //   otp: this.resetPasswordForm.value.otp!,
    //   newPassword: this.resetPasswordForm.value.newPassword!
    // }).subscribe({
    //   next: (response) => {
    //     this.isResetting = false;
    //     if (response.isSuccess) {
    //       this.currentStep = 'success';
    //       this.snackbar.showSuccess('Password has been reset successfully.');
    //     } else {
    //       this.showErrorMessage('Failed to reset password. Please try again.');
    //       this.resetOtpInput();
    //     }
    //   },
    //   error: () => {
    //     this.isResetting = false;
    //     this.showErrorMessage('Failed to reset password. Please try again.');
    //     this.resetOtpInput();
    //   }
    // });
  }
  navigateToLogin(): void {
    this.router.navigate(['/login']);
  }
  goBackToStep(step: 'email' | 'otp' | 'password'): void {
    this.currentStep = step;
    if (step === 'email') {
      this.resetPasswordForm.get('otp')?.setValue('');
      this.otp = '';
    }
  }
  onOtpInput(event: Event): void {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, '');
    if (value.length > 6) {
      value = value.substring(0, 6);
    }
    this.otp = value;
    this.resetPasswordForm.get('otp')?.setValue(value);
    input.value = value;
    input.style.borderColor = '#e2e8f0';
    if (value.length === 6) setTimeout(() => this.verifyOtpAndProceed(), 500);
  }
  onOtpPaste(event: ClipboardEvent): void {
    event.preventDefault();
    const paste = event.clipboardData?.getData('text') || '';
    const digits = paste.replace(/\D/g, '').substring(0, 6);
    this.otp = digits;
    this.resetPasswordForm.get('otp')?.setValue(digits);
    const input = event.target as HTMLInputElement;
    input.value = digits;
    if (digits.length === 6)
      setTimeout(() => this.verifyOtpAndProceed(), 500);
  }
  private resetOtpInput(): void {
    this.otp = '';
    this.resetPasswordForm.get('otp')?.setValue('');
    const otpInput = document.querySelector('.otp-input') as HTMLInputElement;
    if (otpInput) {
      otpInput.value = '';
      otpInput.style.borderColor = '#ef4444';
      otpInput.focus();
      otpInput.style.animation = 'shake 0.5s ease-in-out';
      setTimeout(() => {
        otpInput.style.animation = '';
      }, 500);
    }
  }
  private showErrorMessage(message: string): void {
    this.snackbar.showError(message);
    const container = document.querySelector('.reset-password-container') as HTMLElement;
    if (container) {
      container.style.animation = 'shake 0.5s ease-in-out';
      setTimeout(() => {
        container.style.animation = '';
      }, 500);
    }
  }
  get emailControl() { return this.resetPasswordForm.get('email'); }
  get otpControl() { return this.resetPasswordForm.get('otp'); }
  get newPasswordControl() { return this.resetPasswordForm.get('newPassword'); }
  get confirmPasswordControl() { return this.resetPasswordForm.get('confirmPassword'); }
}
