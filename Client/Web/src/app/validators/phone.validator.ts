import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function phoneValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;

    if (!value) return null;

    const egyptianPhoneRegex = /^(?:\+20|0)?1[0125]\d{8}$/;

    return egyptianPhoneRegex.test(value)
      ? null
      : { invalidEgyptianPhone: true };
  };
}
