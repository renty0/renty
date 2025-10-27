import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule, NgOptimizedImage } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { ToastService } from '../../../../shared/services/toast.service';
import { InputComponent } from '../../../../shared/components/input/input';
import { TranslatePipe } from '@ngx-translate/core';
import { emailValidator } from '../../../../validators/email.validator';
import { passwordValidator } from '../../../../validators/password.validator';

@Component({
  selector: 'app-login',
  imports: [CommonModule, ReactiveFormsModule, TranslatePipe, RouterModule, NgOptimizedImage, ButtonModule, InputComponent],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  private snackbar = inject(ToastService);
  private formBuilder = inject(FormBuilder);
  // private authClient = inject(AuthClient);
  // private authService = inject(AuthService);
  // private router = inject(Router);
  isLoading = false;

  loginForm = this.formBuilder.group({
    email: ['', [Validators.required, emailValidator()]],
    password: ['', [Validators.required, passwordValidator()]],
  });

  onSubmit() {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }
    // this.isLoading = true;
    // const data: LoginCommand = new LoginCommand({
    //   email: this.loginForm.value.email!,
    //   password: this.loginForm.value.password!,
    // });
    // this.authClient.postApiAuthLogin(data).subscribe({
    //   next: (response) => {
    //     this.isLoading = false;
    //     if (response.isSuccess && response.data != undefined) {
    //       this.authService.storeLoginResponse(response.data);
    //       this.router.navigate(['/']);
    //     } else {
    //       if (response.error?.code === 1011) {
    //         this.router.navigate(['/confirm-email'], {
    //           queryParams: { email: this.loginForm.value.email },
    //         });
    //       }
    //     }
    //   },
    //   error: (error) => {
    //     this.isLoading = false;
    //     this.snackbar.showError('Login failed:', error);
    //   },
    // });
    this.snackbar.showInfo('Not supported yet!');
  }
}
