import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { InputComponent } from '../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { LocalizationService } from '../../../core/services/localization.service';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
  selector: 'app-contact-us',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatIconModule,
    InputComponent,
    LoadingButtonComponent
  ],
  templateUrl: './contact-us.component.html',
  styleUrl: './contact-us.component.scss'
})
export class ContactUsComponent {
  private fb = inject(FormBuilder);
  private toast = inject(ToastService);
  private translate = inject(TranslateService);
  localization = inject(LocalizationService);

  contactForm: FormGroup;
  isSubmitting = signal(false);

  constructor() {
    this.contactForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      subject: ['', [Validators.required, Validators.minLength(5)]],
      message: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(1000)]]
    });
  }

  get lang() {
    return this.localization.language();
  }

  onSubmit() {
    if (this.contactForm.invalid) {
      this.contactForm.markAllAsTouched();
      return;
    }

    this.isSubmitting.set(true);

    // Mock API call since no specific backend endpoint exists for public contact us currently
    setTimeout(() => {
      this.isSubmitting.set(false);
      this.toast.showSuccess(this.translate.instant('contact.form.success'));
      this.contactForm.reset();
    }, 1500);
  }
}
