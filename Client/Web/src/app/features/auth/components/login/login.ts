import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import { Router, RouterModule } from '@angular/router';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { AuthService } from '../../../../core/services/auth.service';
import { finalize } from 'rxjs';
import { emailValidator } from '../../../../validators/email.validator';
import { passwordValidator } from '../../../../validators/password.validator';
import { ApiResponse, AuthLoginData } from '../../../../core/api/api-client';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, TranslatePipe, RouterModule, LoadingButtonComponent, InputComponent],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  private snackbar = inject(ToastService);
  private formBuilder = inject(FormBuilder);
  private authService = inject(AuthService);
  private translate = inject(TranslateService);
  private router = inject(Router);

  isLoading = signal(false);

  loginForm = this.formBuilder.group({
    email: ['', [Validators.required, emailValidator()]],
    password: ['', [Validators.required, passwordValidator()]],
  });

  onSubmit() {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    this.isLoading.set(true);

    const email = this.loginForm.value.email!;
    const password = this.loginForm.value.password!;

    this.authService.login(email, password).pipe(finalize(() => this.isLoading.set(false))).subscribe({
      next: (response: ApiResponse<AuthLoginData>) => {
        if (!response.error && response.data) {
          if (this.authService.isSuperAdmin()) {
            this.router.navigate(['/super-admin']);
          } else if (this.authService.isAdmin()) {
            this.router.navigate(['/admin']);
          } else if (this.authService.isExpert()) {
            this.router.navigate(['/expert']);
          } else if (this.authService.isSupport()) {
            this.router.navigate(['/support']);
          } else {
            this.router.navigate(['/']);
          }
        } else if (response.messages?.[0] === 'EmailNotConfirmed') {
          this.snackbar.showInfo(this.translate.instant('login.emailNotConfirmed'));
          this.router.navigate(['/verify-email'], { queryParams: { email } });
        } else {
          let msg = response.messages?.[0];
          if (msg === 'Invalid email or password.') msg = this.translate.instant('login.invalidCredentials');
          this.snackbar.showError(msg || this.translate.instant('login.invalidCredentials'));
        }
      },
      error: (error: { status?: number; error?: { messages?: string[] } }) => {
        const firstMessage = error?.error?.messages?.[0];

        if (firstMessage === 'EmailNotConfirmed') {
          this.snackbar.showInfo(this.translate.instant('login.emailNotConfirmed'));
          this.router.navigate(['/verify-email'], { queryParams: { email } });
        } else {
          let msg = firstMessage;
          if (firstMessage === 'Invalid email or password.' || error.status === 401) {
            msg = this.translate.instant('login.invalidCredentials');
          } else {
            msg = firstMessage ?? this.translate.instant('login.serverError');
          }
          this.snackbar.showError(msg || this.translate.instant('login.serverError'));
        }
      }
    });
  }
}

