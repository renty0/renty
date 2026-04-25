import { Component, inject, signal, OnInit } from '@angular/core';
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
  ],
  templateUrl: './verify-email.component.html',
  styleUrl: '../login/login.scss',
})
export class VerifyEmailComponent implements OnInit {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private toast = inject(ToastService);
  private translate = inject(TranslateService);

  loading = signal(false);
  verified = signal(false);

  verifyForm = this.fb.group({
    email: ['', [Validators.required, emailValidator()]],
    code: ['', [Validators.required, Validators.minLength(1)]],
  });

  ngOnInit() {
    const email = this.route.snapshot.queryParamMap.get('email');
    const code = this.route.snapshot.queryParamMap.get('code');
    if (email) {
      this.verifyForm.patchValue({ email });
    }
    if (email && code) {
      this.verifyForm.patchValue({ code });
      this.submit();
    }
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
