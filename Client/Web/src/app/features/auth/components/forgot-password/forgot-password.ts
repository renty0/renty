import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { AuthClient, ForgotPasswordCommand } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { catchError, finalize, of } from 'rxjs';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    TranslateModule,
    InputComponent,
    LoadingButtonComponent,
  ],
  templateUrl: './forgot-password.html',
  styleUrl: '../login/login.scss',
})
export class ForgotPassword {
  private fb = inject(FormBuilder);
  private authClient = inject(AuthClient);
  private toastService = inject(ToastService);
  private router = inject(Router);
  private translate = inject(TranslateService);

  forgotForm: FormGroup;
  isLoading = signal(false);
  isSubmitted = signal(false);

  constructor() {
    this.forgotForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
    });
  }

  onSubmit() {
    if (this.forgotForm.invalid) {
      this.forgotForm.markAllAsTouched();
      return;
    }

    this.isLoading.set(true);
    const email = this.forgotForm.value.email;
    const command = new ForgotPasswordCommand({ email });

    this.authClient
      .authForgotPassword(command)
      .pipe(
        finalize(() => this.isLoading.set(false)),
        catchError((err) => {
          this.toastService.showError(this.translate.instant('forgotPassword.errorDesc'));
          return of(null);
        }),
      )
      .subscribe((res) => {
        if (res && res.error) {
          this.toastService.showError(res.messages?.[0] || this.translate.instant('forgotPassword.errorDesc'));
        } else {
          this.isSubmitted.set(true);
          this.toastService.showSuccess(this.translate.instant('resetPassword.successDesc'));
          this.forgotForm.get('email')?.setValue('');
          this.forgotForm.reset();
        }
      });
  }
}
