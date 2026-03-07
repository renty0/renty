import { HttpInterceptorFn, HttpErrorResponse, HttpRequest, HttpHandlerFn, HttpEvent } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError, switchMap, BehaviorSubject, filter, take, Observable } from 'rxjs';
import { AuthService } from '../services/auth.service';
import { ToastService } from '../../shared/services/toast.service';
// import { AuthClient, RefreshTokenCommand, UserSessionDto } from '../../../../api-client';

let isRefreshing = false;
const refreshTokenSubject = new BehaviorSubject<string | null>(null);

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const toastService = inject(ToastService);
  const authService = inject(AuthService);
  // const authClient = inject(AuthClient);
  const router = inject(Router);
  const publicEndpoints = ['/Login', '/Register', '/SendConfirmationEmail', '/ConfirmEmail', '/RefreshToken'];
  const isPublicEndpoint = publicEndpoints.some(endpoint => req.url.includes(endpoint));

  // if (isPublicEndpoint) return next(req);
  // if (!authService.isAuthenticated()) {
  //   toastService.showWarning('User not authenticated - redirecting to login');
  //   authService.logout();
  //   return throwError(() => new HttpErrorResponse({
  //     error: 'User not authenticated', status: 401, statusText: 'Unauthorized'
  //   }));
  // }
  const authReq = addTokenToRequest(req, authService.getToken());
  return next(authReq).pipe(
    catchError((error: HttpErrorResponse) => {
      // toastService.showError(`HTTP Error occurred, with satus: ${error.status}, with message: ${error.message}`);
      // if (error.status === 401 && !isPublicEndpoint) return handle401Error(req, next, authService,
        //  authClient,
        //  router, toastService);
      // handleOtherErrors(error, authService, router, toastService);
      return throwError(() => error);
    })
  );
};
function addTokenToRequest(req: HttpRequest<any>, token: string | null): HttpRequest<any> {
  if (token) return req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  return req;
}
// function handle401Error( req: HttpRequest<any>, next: HttpHandlerFn, authService: AuthService, authClient: AuthClient, router: Router, toastService: ToastService ): Observable<HttpEvent<unknown>> {
function handle401Error( req: HttpRequest<any>, next: HttpHandlerFn, authService: AuthService, router: Router, toastService: ToastService ): Observable<HttpEvent<unknown>> {
  if (!authService.hasValidRefreshToken()) {
    toastService.showWarning('No valid refresh token - redirecting to login');
    handleTokenExpired(authService, router);
    return throwError(() => new Error('No valid refresh token'));
  }
  if (isRefreshing)
    return refreshTokenSubject.pipe(
      filter(token => token !== null), take(1),
      switchMap(token => next(addTokenToRequest(req, token)))
    );
  isRefreshing = true;
  refreshTokenSubject.next(null);
  const accessToken = authService.getToken() || '';
  return throwError(() => new Error('Token refresh logic not implemented'));
  // return authClient.patchApiAuthRefreshToken(new RefreshTokenCommand({ accessToken })).pipe(
  //   switchMap((response: UserSessionDto) => {
  //     isRefreshing = false;
  //     if (response && response.accessToken) {
  //       authService.storeLoginResponse(response);
  //       refreshTokenSubject.next(response.accessToken);
  //       return next(addTokenToRequest(req, response.accessToken));
  //     } else {
  //       toastService.showError('Token refresh failed - no access token in response');
  //       handleTokenExpired(authService, router);
  //       return throwError(() => new Error('Token refresh failed'));
  //     }
  //   }),
  //   catchError(refreshError => {
  //     isRefreshing = false;
  //     refreshTokenSubject.next(null);
  //     toastService.showError('Token refresh failed:', refreshError);
  //     handleTokenExpired(authService, router);
  //     return throwError(() => refreshError);
  //   })
  // );
}
function handleOtherErrors(error: HttpErrorResponse, authService: AuthService, router: Router, toastService: ToastService): void {
  switch (error.status) {
    case 403:
      toastService.showWarning('Access forbidden - Insufficient permissions');
      handleForbidden(router);
      break;
    case 422:
      toastService.showWarning('Validation error:', error.error);
      break;
    case 429:
      toastService.showWarning('Too many requests - Please try again later');
      break;
    case 500:
      toastService.showError('Server error occurred');
      break;
    case 502:
    case 503:
    case 504:
      toastService.showError('Service temporarily unavailable');
      break;
    case 0:
      toastService.showError('Network error - Check your internet connection');
      break;
    default:
      toastService.showError(`Unexpected HTTP Error, with status: ${error.status}, with message ${error.message}` );
  }
}
function handleTokenExpired(authService: AuthService, router: Router): void {
  authService.removeAuthData();
  const currentUrl = router.url;
  router.navigate(['/login'], {
    queryParams: {
      returnUrl: currentUrl !== '/login' ? currentUrl : null,
      reason: 'session_expired'
    }
  });
}
function handleForbidden(router: Router): void {
  router.navigate(['/access-denied'], {
    queryParams: {reason: 'insufficient_permissions'}
  });
}
