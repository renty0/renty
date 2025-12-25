import { Component, inject, Input, OnDestroy } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { IconFieldModule } from 'primeng/iconfield';
import { InputIconModule } from 'primeng/inputicon';
import { PasswordModule } from 'primeng/password';
import { TranslatePipe } from '@ngx-translate/core';
import { SelectModule } from 'primeng/select';
import { DatePicker } from 'primeng/datepicker';
import { FloatLabelModule } from 'primeng/floatlabel';
import { InputNumber } from 'primeng/inputnumber';
import { LocalizationService } from '../../../core/services/localization.service';
import { TextareaModule } from 'primeng/textarea';
import { MultiSelectModule } from 'primeng/multiselect';
@Component({
  selector: 'app-input',
  standalone: true,
  imports: [ CommonModule, MultiSelectModule, ReactiveFormsModule, FloatLabelModule, TextareaModule, InputNumber, InputTextModule, SelectModule, IconFieldModule, InputIconModule, PasswordModule, TranslatePipe, DatePicker ],
  templateUrl: './input.html',
  styleUrls: ['./input.scss'],
})
export class InputComponent {
  private localizationService = inject(LocalizationService);
  language: 'ar' | 'en' = 'ar';
  @Input() label!: string;
  @Input() formGroup!: FormGroup;
  @Input() controlName!: string;
  @Input() type = 'text';
  @Input() height = 48;
  @Input() options: { name: string, code: number }[] = [];
  @Input() disabled = false;
  @Input() value = '';
  @Input() readonly = false;

 // For Date
  @Input() minDate?: Date;
  @Input() maxDate?: Date;

  constructor() {
    this.language = this.localizationService.getLanguage();
  }
  get formControl(): FormControl {
    return this.formGroup.get(this.controlName) as FormControl;
  }

  get hasError(): boolean {
    return this.formControl?.invalid && this.formControl.touched;
  }

  get errorMessages(): string[] {
    if (!this.hasError) return [];
    const errors = this.formControl.errors;
    const messages: string[] = [];
    if (errors?.['required']) messages.push('validation.required');
    if (errors?.['invalidEmail']) messages.push('validation.invalidEmail');
    if (errors?.['minlength']) messages.push('validation.minLength');
    if (errors?.['maxlength']) messages.push('validation.maxLength');
    if (errors?.['pattern']) messages.push('validation.invalidFormat');
    if (errors?.['invalidPostalCode']) messages.push('validation.invalidPostalCode');
    if (errors?.['invalidPhone']) messages.push('validation.invalidPhone');
    if (errors?.['invalidAge']) messages.push('validation.invalidAge');
    if (errors?.['invalidRegistrationNumber']) messages.push('validation.invalidRegistrationNumber');
    if (errors?.['invalidTaxNumber']) messages.push('validation.invalidTaxNumber');
    if (errors?.['invalidHeight']) messages.push('validation.invalidHeight');
    if (errors?.['invalidWeight']) messages.push('validation.invalidWeight');
    if (errors?.['passwordMismatch']) messages.push('validation.passwordMismatch');
    if (errors?.['invalidImageUrl']) messages.push('validation.invalidImageUrl');
    if (errors?.['invalidMap']) messages.push('validation.invalidMap');
    if (errors?.['invalidUnifiedNumber']) messages.push('validation.invalidUnifiedNumber');
    if (errors?.['invalidPassword']) {
      const missing = [];
      if (!errors['invalidPassword'].hasUpperCase) missing.push('validation.missingUpperCase');
      if (!errors['invalidPassword'].hasNumber) missing.push('validation.missingNumber');
      if (!errors['invalidPassword'].hasSpecialChar) missing.push('validation.missingSpecialChar');
      messages.push(...missing);
    }
    return messages;
  }
}
