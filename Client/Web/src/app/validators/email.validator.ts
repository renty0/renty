import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

// Email Validator (built-in but included for consistency)
export function emailValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return control.value && !emailRegex.test(control.value)
      ? {invalidEmail: true}
      : null;
  };
}
