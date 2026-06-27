import { inject, Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastService } from '../../shared/services/toast.service';

@Injectable({
    providedIn: 'root'
})
export class SupportGuard implements CanActivate {
    private authService = inject(AuthService);
    private router = inject(Router);
    private toast = inject(ToastService);

    canActivate(_route: ActivatedRouteSnapshot, _state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
        if (!this.authService.isLoggedIn()) {
            this.router.navigate(['/login'], { queryParams: { returnUrl: _state.url } });
            return false;
        }

        if (this.authService.isSupport()) {
            return true;
        }

        this.toast.showError('errors.adminAccessDenied');
        this.router.navigate(['/']);
        return false;
    }
}
