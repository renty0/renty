import { Component, inject, Input, signal, ChangeDetectionStrategy, DestroyRef, ChangeDetectorRef, OnInit, AfterViewInit } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule, ValidationErrors } from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { TranslatePipe } from '@ngx-translate/core';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatChipInputEvent, MatChipsModule } from '@angular/material/chips';
import { NgxMatTimepickerModule } from 'ngx-mat-timepicker';
import { MatDialog } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { COMMA, ENTER } from '@angular/cdk/keycodes';
import { LocalizationService } from '../../../core/services/localization.service';

const ERROR_MESSAGE_MAP: Record<string, string> = {
  required: 'validation.required',
  email: 'validation.invalidEmail',
  invalidEmail: 'validation.invalidEmail',
  minlength: 'validation.minLength',
  maxlength: 'validation.maxLength',
  pattern: 'validation.invalidFormat',
  invalidPostalCode: 'validation.invalidPostalCode',
  invalidPhone: 'validation.invalidPhone',
  invalidAge: 'validation.invalidAge',
  invalidRegistrationNumber: 'validation.invalidRegistrationNumber',
  invalidTaxNumber: 'validation.invalidTaxNumber',
  invalidHeight: 'validation.invalidHeight',
  invalidWeight: 'validation.invalidWeight',
  passwordMismatch: 'validation.passwordMismatch',
  invalidImageUrl: 'validation.invalidImageUrl',
  invalidMap: 'validation.invalidMap',
  invalidUnifiedNumber: 'validation.invalidUnifiedNumber',
};

export type InputType = 'text' | 'email' | 'password' | 'number' | 'tel' | 'phone' | 'url' | 'search' | 'date' | 'time' | 'select' | 'multiselect' | 'textarea' | 'confirmPassword' | 'chips' | 'image-picker';
export type InputSize = 'sm' | 'md' | 'lg';
export interface SelectOption {
  name: string;
  code: number | string;
}
@Component({
  selector: 'app-input',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatIconModule, TranslatePipe, MatDatepickerModule, MatNativeDateModule, MatChipsModule, MatButtonModule, NgxMatTimepickerModule],
  templateUrl: './input.html',
  styleUrls: ['./input.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class InputComponent implements OnInit, AfterViewInit {
  private readonly localizationService = inject(LocalizationService);
  private readonly dialog = inject(MatDialog);
  private readonly destroyRef = inject(DestroyRef);
  private readonly cdr = inject(ChangeDetectorRef);


  @Input() label!: string;
  @Input() formGroup!: FormGroup;
  @Input() controlName!: string;
  @Input() type: InputType = 'text';
  @Input() height = 48;
  @Input() options: SelectOption[] = [];
  @Input() disabled = false;
  @Input() value = '';
  @Input() required = false;
  @Input() readonly = false;
  @Input() placeholder = '';
  @Input() hint = '';
  @Input() prefixIcon = '';
  @Input() suffixIcon = '';
  @Input() suffixText = '';
  @Input() size: InputSize = 'md';
  @Input() minDate?: Date;
  @Input() maxDate?: Date;
  @Input() min?: number;
  @Input() max?: number;
  @Input() step?: number;
  @Input() maxLength?: number;
  @Input() rows = 4;
  @Input() autocomplete = 'off';
  @Input() translateLabel = true;
  @Input() translateOptions = false;
  @Input() textDirection: 'ltr' | 'rtl' | 'auto' = 'auto';

  isFocused = signal(false);
  showPassword = signal(false);

  // Chip input separators
  readonly separatorKeyCodes = [ENTER, COMMA] as const;

  get language(): 'ar' | 'en' {
    return this.localizationService.language();
  }

  onFocus(): void {
    if (!this.readonly && !this.disabled) {
      this.isFocused.set(true);
    }
  }

  onBlur(): void {
    this.isFocused.set(false);
    this.formControl?.markAsTouched();
  }

  get isFloating(): boolean {
    return this.isFocused() || !!this.formControl?.value || !!this.placeholder || this.type === 'date' || this.type === 'time' || this.type === 'chips' || this.type === 'image-picker';
  }

  get hasValue(): boolean {
    return !!this.formControl?.value;
  }

  ngOnInit(): void {
    // Subscribe to value changes for ALL types so OnPush detects external patchValue calls
    if (this.formControl) {
      this.formControl.valueChanges
        .pipe(takeUntilDestroyed(this.destroyRef))
        .subscribe(() => {
          this.markTouchedIfHasValue();
          this.cdr.markForCheck();
        });
    }

    // Edit/update mode: if the control already has a value on init,
    // mark it touched so the floating label and valid state appear immediately
    this.markTouchedIfHasValue();
  }

  ngAfterViewInit(): void {
    // Second pass: handles async patchValue where parent populates the form
    // after ngOnInit (e.g. after an API call resolves)
    this.markTouchedIfHasValue();
  }

  /** Marks the control as touched + triggers re-render if it already holds a value. */
  private markTouchedIfHasValue(): void {
    if (this.formControl?.value != null && this.formControl.value !== '') {
      this.formControl.markAsTouched();
      this.cdr.markForCheck();
    }
  }

  get chipsArray(): string[] {
    const value = this.formControl?.value;
    if (!value || typeof value !== 'string') return [];
    return value.split(',').map((s: string) => s.trim()).filter((s: string) => s.length > 0);
  }
  addChip(event: MatChipInputEvent): void {
    const value = (event.value || '').trim();
    if (value) {
      const chips = this.chipsArray;
      if (!chips.includes(value)) {
        chips.push(value);
        this.formControl.setValue(chips.join(', '));
        this.formControl.markAsTouched();
      }
    }
    event.chipInput.clear();
  }
  removeChip(chip: string): void {
    const chips = this.chipsArray.filter(c => c !== chip);
    this.formControl.setValue(chips.join(', '));
    this.formControl.markAsTouched();
  }

  get formControl(): FormControl {
    return this.formGroup.get(this.controlName) as FormControl;
  }

  get hasError(): boolean {
    return this.formControl?.invalid && this.formControl.touched;
  }

  get isValid(): boolean {
    return this.formControl?.valid && this.formControl.touched && this.formControl.value;
  }

  get errorMessages(): string[] {
    if (!this.hasError) return [];
    const errors = this.formControl.errors;
    if (!errors) return [];

    const messages = this.getStandardErrorMessages(errors);
    messages.push(...this.getPasswordErrorMessages(errors));
    return messages;
  }

  get inputType(): string {
    if (this.type === 'password' || this.type === 'confirmPassword') {
      return this.showPassword() ? 'text' : 'password';
    }
    return this.type;
  }

  get heightPx(): number {
    switch (this.size) {
      case 'sm': return 40;
      case 'lg': return 56;
      default: return this.height || 48;
    }
  }

  get prefixIconName(): string {
    if (this.prefixIcon) return this.prefixIcon;
    switch (this.type) {
      case 'email': return 'email';
      case 'tel': return 'phone';
      case 'password':
      case 'confirmPassword': return 'lock';
      case 'search': return 'search';
      case 'url': return 'link';
      default: return '';
    }
  }
  get translatedLabel(): string {
    if (!this.label) return '';
    if (!this.translateLabel) return this.label;
    if (this.label.includes('.')) return this.label;
    return 'labels.' + this.label;
  }
  get inputTextDir(): 'ltr' | 'rtl' {
    if (this.textDirection !== 'auto') return this.textDirection;
    return this.language === 'ar' ? 'rtl' : 'ltr';
  }
  togglePasswordVisibility(): void {
    this.showPassword.update(v => !v);
  }
  trackOption(index: number, option: SelectOption): number | string {
    return option.code;
  }
  private getStandardErrorMessages(errors: ValidationErrors): string[] {
    return Object.keys(errors).filter(key => key in ERROR_MESSAGE_MAP).map(key => ERROR_MESSAGE_MAP[key]);
  }
  private getPasswordErrorMessages(errors: ValidationErrors): string[] {
    const passwordError = errors['invalidPassword'];
    if (!passwordError) return [];

    const messages: string[] = [];
    if (!passwordError.hasUpperCase) messages.push('validation.missingUpperCase');
    if (!passwordError.hasNumber) messages.push('validation.missingNumber');
    if (!passwordError.hasSpecialChar) messages.push('validation.missingSpecialChar');
    return messages;
  }

  // Image picker methods
  openMediaPicker(): void {
    // Stub for Media Picker Dialog if it is implemented in the future.
    // Ensure image-picker inputs are correctly integrated.
  }

  clearImage(): void {
    this.formControl.setValue('');
    this.formControl.markAsTouched();
    this.cdr.markForCheck();
  }

  get hasImageValue(): boolean {
    return !!this.formControl?.value;
  }

  get imagePreviewUrl(): string {
    return this.formControl?.value || '';
  }
}
