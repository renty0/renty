import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function passwordValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;

    const hasUpperCase = /[A-Z]/.test(control.value);
    const hasNumber = /[0-9]/.test(control.value);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(control.value);

    return hasUpperCase && hasNumber && hasSpecialChar
      ? null
      : { invalidPassword: { hasUpperCase, hasNumber, hasSpecialChar } };
  };
}
