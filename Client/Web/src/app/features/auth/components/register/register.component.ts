import { Component, inject, signal, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { TranslatePipe, TranslateService } from '@ngx-translate/core';
import { MatStepperModule } from '@angular/material/stepper';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { finalize } from 'rxjs';
import { InputComponent } from '../../../../shared/components/input/input';
import { ToastService } from '../../../../shared/services/toast.service';
import { emailValidator } from '../../../../validators/email.validator';
import { passwordValidator } from '../../../../validators/password.validator';
import { phoneValidator } from '../../../../validators/phone.validator';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { ApiResponse, AuthRegisterData, UserType } from '../../../../core/api/api-client';
import { TermsAndConditionsComponent } from '../terms-and-conditions/terms-and-conditions.component';
import { AuthService } from '../../../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    CommonModule,
    RouterModule,
    TranslatePipe,
    MatStepperModule,
    MatButtonModule,
    MatIconModule,
    MatCheckboxModule,
    InputComponent,
    LoadingButtonComponent,
    TermsAndConditionsComponent
  ],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent implements OnInit {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private toast = inject(ToastService);
  translate = inject(TranslateService);

  loading = signal(false);
  formSubmitted = signal(false);
  showTerms = signal(false);

  accountInfoGroup!: FormGroup;
  profileInfoGroup!: FormGroup;
  additionalInfoGroup!: FormGroup;
  registerForm!: FormGroup;

  userTypeOptions = [
    {
      name: 'Renter',
      code: UserType.Renter,
      icon: 'shopping_basket',
      titleKey: 'register.roles.renterTitle',
      descKey: 'register.roles.renterDesc'
    },
    {
      name: 'Owner',
      code: UserType.Owner,
      icon: 'storefront',
      titleKey: 'register.roles.ownerTitle',
      descKey: 'register.roles.ownerDesc'
    },
    {
      name: 'Both',
      code: UserType.Both,
      icon: 'diversity_3',
      titleKey: 'register.roles.memberTitle',
      descKey: 'register.roles.memberDesc'
    }
  ];

  ngOnInit() {
    this.accountInfoGroup = this.fb.group({
      email: ['', [Validators.required, emailValidator()]],
      password: ['', [Validators.required, Validators.minLength(6), passwordValidator()]],
      confirmPassword: ['', [Validators.required]],
    }, { validators: this.passwordMatchValidator });

    this.profileInfoGroup = this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2)]],
      lastName: ['', [Validators.required, Validators.minLength(2)]],
      phoneNumber: ['', [phoneValidator()]],
    });

    this.additionalInfoGroup = this.fb.group({
      userType: [UserType.Renter, [Validators.required]],
      bio: [''],
      address: [''],
      city: [''],
      country: [''],
      acceptTerms: [false, [Validators.requiredTrue]],
    });

    this.registerForm = this.fb.group({
      accountInfo: this.accountInfoGroup,
      profileInfo: this.profileInfoGroup,
      additionalInfo: this.additionalInfoGroup,
    });
  }

  passwordMatchValidator(g: FormGroup) {
    const password = g.get('password')?.value;
    const confirmPassword = g.get('confirmPassword')?.value;
    return password === confirmPassword ? null : { passwordMismatch: true };
  }

  onSubmit() {
    this.formSubmitted.set(true);
    if (this.registerForm.invalid) {
      this.registerForm.markAllAsTouched();
      return;
    }

    this.loading.set(true);

    const payload = {
      email: this.accountInfoGroup.value.email,
      password: this.accountInfoGroup.value.password,
      confirmPassword: this.accountInfoGroup.value.confirmPassword,
      firstName: this.profileInfoGroup.value.firstName,
      lastName: this.profileInfoGroup.value.lastName,
      phoneNumber: this.profileInfoGroup.value.phoneNumber || undefined,
      address: this.additionalInfoGroup.value.address || undefined,
      city: this.additionalInfoGroup.value.city || undefined,
      country: this.additionalInfoGroup.value.country || undefined,
      bio: this.additionalInfoGroup.value.bio || undefined,
      userType: this.additionalInfoGroup.value.userType
    };

    this.authService.register(payload).pipe(
      finalize(() => this.loading.set(false))
    ).subscribe({
      next: (response: ApiResponse<AuthRegisterData>) => {
        if (!response.error) {
          this.toast.showSuccess(this.translate.instant('register.successVerifyEmail'));
          this.router.navigate(['/verify-email'], {
            queryParams: { email: this.accountInfoGroup.value.email }
          });
        } else {
          this.toast.showError(response.messages?.[0] || this.translate.instant('register.failed'));
        }
      },
      error: (error: { error?: { messages?: string[] }; message?: string }) => {
        const msg = error?.error?.messages?.[0] ?? error?.message ?? this.translate.instant('login.serverError');
        this.toast.showError(msg);
      }
    });
  }
}
