import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import {
  AuthClient,
  ResetPasswordCommand,
  ForgotPasswordCommand,
  VerifyResetTokenCommand,
} from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    TranslateModule,
    InputComponent,
    LoadingButtonComponent,
  ],
  templateUrl: './reset-password.html',
  styleUrl: '../login/login.scss', // reuse login styles
})
export class ResetPassword {
  private fb = inject(FormBuilder);
  private authClient = inject(AuthClient);
  private toastService = inject(ToastService);
  private router = inject(Router);
  private translate = inject(TranslateService);

  resetForm: FormGroup;
  isLoading = signal(false);
  step = signal(1); // 1: Request Code, 2: Verify Code, 3: Reset Password

  constructor() {
    this.resetForm = this.fb.group(
      {
        email: ['', [Validators.required, Validators.email]],
        token: [{ value: '', disabled: true }, [Validators.required]],
        newPassword: [
          { value: '', disabled: true },
          [Validators.required, Validators.minLength(6)],
        ],
        confirmPassword: [{ value: '', disabled: true }, [Validators.required]],
      },
      { validators: this.passwordMatchValidator },
    );
  }

  passwordMatchValidator(g: FormGroup) {
    return g.get('newPassword')?.value === g.get('confirmPassword')?.value
      ? null
      : { mismatch: true };
  }

  onSubmit() {
    if (this.step() === 1) {
      this.requestResetCode();
    } else if (this.step() === 2) {
      this.verifyResetCode();
    } else {
      this.resetPassword();
    }
  }

  requestResetCode() {
    const emailControl = this.resetForm.get('email');
    if (emailControl?.invalid) {
      emailControl.markAsTouched();
      return;
    }

    this.isLoading.set(true);
    const email = emailControl?.value;
    const command = new ForgotPasswordCommand({ email });

    this.authClient
      .authForgotPassword(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError((err) => {
          return of(null);
        }),
        tap((res) => {
          if (res && res.error) {
            this.toastService.showError(
              res.messages?.[0] || this.translate.instant('forgotPassword.errorDesc'),
            );
          } else {
            this.toastService.showSuccess(
              res?.messages?.[0] || this.translate.instant('resetPassword.successDesc'),
            );
            this.step.set(2);
            this.resetForm.get('email')?.disable();
            this.resetForm.get('token')?.enable();
          }
        }),
      )
      .subscribe();
  }

  verifyResetCode() {
    const tokenControl = this.resetForm.get('token');
    if (tokenControl?.invalid) {
      tokenControl.markAsTouched();
      return;
    }

    this.isLoading.set(true);
    const email = this.resetForm.getRawValue().email;
    const token = tokenControl?.value;
    const command = new VerifyResetTokenCommand({ email, token });

    this.authClient
      .authVerifyResetCode(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError(() => {
          this.toastService.showError(this.translate.instant('resetPassword.invalidCode'));
          return of(null);
        }),
      )
      .subscribe((res) => {
        if (res && res.error) {
          this.toastService.showError(
            res.messages?.[0] || this.translate.instant('resetPassword.invalidCode'),
          );
        } else {
          this.toastService.showSuccess(this.translate.instant('resetPassword.codeVerified'));
          this.step.set(3);
          this.resetForm.get('token')?.disable();
          this.resetForm.get('newPassword')?.enable();
          this.resetForm.get('confirmPassword')?.enable();
        }
      });
  }

  resetPassword() {
    if (this.resetForm.invalid) {
      this.resetForm.markAllAsTouched();
      return;
    }

    this.isLoading.set(true);
    const formValue = this.resetForm.getRawValue();
    const command = new ResetPasswordCommand({
      email: formValue.email,
      token: formValue.token,
      newPassword: formValue.newPassword,
    });

    this.authClient
      .authResetPassword(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError((err) => {
          this.toastService.showError(this.translate.instant('resetPassword.errorDesc'));
          return of(null);
        }),
      )
      .subscribe((res: any) => {
        if (res && res.error) {
          this.toastService.showError(
            res.messages?.[0] || this.translate.instant('resetPassword.errorDesc'),
          );
        } else {
          this.toastService.showSuccess(
            res?.messages?.[0] || this.translate.instant('resetPassword.successDesc'),
          );
          this.router.navigate(['/login']);
        }
      });
  }
}
