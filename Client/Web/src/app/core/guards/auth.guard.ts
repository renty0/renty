import { inject, Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastService } from '../../shared/services/toast.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  private authService = inject(AuthService);
  private router = inject(Router);
  private toast = inject(ToastService);

  canActivate( _route: ActivatedRouteSnapshot, state: RouterStateSnapshot ): Observable<boolean> | Promise<boolean> | boolean {
    if (this.authService.isLoggedIn()) return true;
    
    this.toast.showInfo('errors.loginRequired');
    this.router.navigate(['/login'], {queryParams: { returnUrl: state.url }});
    return false;
  }
}
