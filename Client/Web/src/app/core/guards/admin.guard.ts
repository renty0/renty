import { inject, Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastService } from '../../shared/services/toast.service';
import { PermissionService } from '../services/permission.service';

@Injectable({
    providedIn: 'root'
})
export class AdminGuard implements CanActivate {
    private authService = inject(AuthService);
    private router = inject(Router);
    private toast = inject(ToastService);
    private permissionService = inject(PermissionService);

    canActivate(_route: ActivatedRouteSnapshot, _state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
        if (!this.authService.isLoggedIn()) {
            this.router.navigate(['/login'], { queryParams: { returnUrl: _state.url } });
            return false;
        }

        const requiredPermission = _route.data['permission'];
        if (requiredPermission) {
            if (this.permissionService.hasPermission(requiredPermission)) {
                return true;
            }
        } else if (this.authService.isAdmin() || this.authService.isSuperAdmin()) {
            return true;
        }

        if (!this.authService.isLoggedIn()) {
            this.router.navigate(['/login'], { queryParams: { returnUrl: _state.url } });
        } else {
            this.toast.showError('errors.adminAccessDenied');
            this.router.navigate(['/']);
        }

        return false;
    }
}
