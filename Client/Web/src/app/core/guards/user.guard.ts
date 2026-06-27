import { inject, Injectable } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class UserGuard implements CanActivate {
  private authService = inject(AuthService);
  private router = inject(Router);

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    if (this.authService.isUser()) {
      return true;
    }

    // Redirect non-users to their respective dashboards
    if (this.authService.isSuperAdmin()) {
      this.router.navigate(['/super-admin/dashboard']);
    } else if (this.authService.isAdmin()) {
      this.router.navigate(['/admin/disputes/open']);
    } else if (this.authService.isSupport()) {
      this.router.navigate(['/support/tickets']);
    } else if (this.authService.isExpert()) {
      this.router.navigate(['/expert/assigned']);
    } else {
      this.router.navigate(['/']); // Fallback
    }
    return false;
  }
}
