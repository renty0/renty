import { inject, Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastService } from '../../shared/services/toast.service';

@Injectable({
  providedIn: 'root'
})
export class VerifiedGuard implements CanActivate {
  private authService = inject(AuthService);
  private router = inject(Router);
  private toastService = inject(ToastService);

  canActivate(_route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
    if (!this.authService.isLoggedIn()) {
      this.router.navigate(['/auth/login'], { queryParams: { returnUrl: state.url } });
      return false;
    }

    if (this.authService.isUserVerified()) {
      return true;
    }

    this.toastService.showInfo('profile.identityVerificationRequired');
    this.router.navigate(['/profile'], { queryParams: { verify: 'true' } });
    return false;
  }
}
