import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { ToastService } from '../../shared/services/toast.service';

export const toasterInterceptor: HttpInterceptorFn = (req, next) => {
    const toast = inject(ToastService);

    return next(req).pipe(
        catchError((error: HttpErrorResponse) => {
            handleError(error, toast);
            return throwError(() => error);
        })
    );
};

async function handleError(error: HttpErrorResponse, toast: ToastService): Promise<void> {
    let errorBody = error.error;
    if (errorBody instanceof Blob) {
        const text = await errorBody.text();
        try {
            errorBody = JSON.parse(text);
        } catch {
            errorBody = { detail: text };
        }
    }

    if (error.status === 401) {
        return;
    }

    if (error.status === 403) {
        toast.showError("You don't have permissions.");
        return;
    }

    switch (error.status) {
        case 400:
            if (errorBody?.errors) {
                const allErrors: string[] = [];
                for (const [field, messages] of Object.entries(errorBody.errors)) {
                    const fieldErrors = messages as string[];
                    allErrors.push(`${field}: ${fieldErrors.join(', ')}`);
                }
                if (allErrors.length > 0) {
                    toast.showError('Validation Errors', { detail: allErrors.join('\n'), life: 10000 });
                }
            } else if (errorBody?.detail) {
                toast.showError(errorBody.detail);
            } else if (errorBody?.message) {
                toast.showError(errorBody.message);
            } else {
                toast.showError('Bad request - Please check your input');
            }
            break;
        default:
            if (error.status >= 400 && error.status < 500) {
                toast.showError('Request failed - Please try again');
            } else if (error.status >= 500) {
                toast.showError('An unexpected error occurred');
            }
    }
}
