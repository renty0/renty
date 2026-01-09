import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { AuthService } from '../../../../core/services/auth.service';
import { finalize, catchError } from 'rxjs';
import { of } from 'rxjs';
import { emailValidator } from '../../../../validators/email.validator';
import { passwordValidator } from '../../../../validators/password.validator';

@Component({
  selector: 'app-login',
  imports: [CommonModule, ReactiveFormsModule, TranslatePipe, RouterModule, LoadingButtonComponent, InputComponent],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  private snackbar = inject(ToastService);
  private formBuilder = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private apiClient = inject(Client);
  private translate = inject(TranslateService);

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
    const loginData = new LoginCommand({
      email: this.loginForm.value.email!,
      password: this.loginForm.value.password!
    });

    this.apiClient.postApiIdentityLogin(loginData).pipe(
      finalize(() => this.isLoading.set(false))
    ).subscribe({
      next: (response) => {
        if (response != undefined) {
          this.authService.storeLoginResponse(response);
          this.router.navigate(['/']);
          this.fetchProfileScore();
        }
      },
      error: (error: ApiException | unknown) => {
        if (error instanceof ApiException) {
          if (error.status === 401) {
            this.snackbar.showError(
              this.translate.currentLang === 'ar'
                ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
                : 'Invalid email or password'
            );
          } else if (error.status === 400) {
            try {
              const errorBody = JSON.parse(error.response);
              if (errorBody?.requiresEmailConfirmation) {
                const email = errorBody.email || this.loginForm.value.email;
                this.snackbar.showWarning(
                  this.translate.currentLang === 'ar'
                    ? 'البريد الإلكتروني غير مؤكد. يرجى تأكيد بريدك الإلكتروني.'
                    : 'Email not confirmed. Please confirm your email.'
                );
                this.router.navigate(['/confirm-email'], { queryParams: { email } });
              }
            } catch {
            }
          }
        }
      }
    });
  }

  private fetchProfileScore(): void {
    const userType = this.profileCompletionService.getUserType();
    if (!userType) return;

    let scoreObservable;
    if (userType === 'Facility') {
      scoreObservable = this.profileCompletionService.getFacilityProfileScore();
    } else if (userType === 'Company') {
      scoreObservable = this.profileCompletionService.getCompanyProfileScore();
    } else if (userType === 'Guard') {
      scoreObservable = this.profileCompletionService.getGuardProfileScore();
    }

    if (scoreObservable) {
      scoreObservable.pipe(catchError(() => of(null))).subscribe((res) => {
        if (res?.data?.percentage !== undefined && res.data.percentage < 100) {
          this.snackbar.showProfileCompletionRequired();
        }
      });
    }
  }
}
