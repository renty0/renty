import { computed, inject, Injectable, signal, WritableSignal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { ToastService } from '../../shared/services/toast.service';
import { LoginResponse, UserDto, AccountClient, RefreshTokenCommand } from '../api/api-client';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly toast = inject(ToastService);
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);

  private readonly ACCESS_TOKEN_KEY = 'access_token';
  private readonly REFRESH_TOKEN_KEY = 'refresh_token';
  private readonly REFRESH_TOKEN_EXP_KEY = 'refresh_token_exp';
  private readonly USER_DATA_KEY = 'user_data';
  private readonly ROLES_KEY = 'user_roles';

  isLoggedIn: WritableSignal<boolean>;
  private readonly rolesSignal = signal<string[]>([]);
  readonly roles = computed(() => this.rolesSignal());

  private isRefreshing = false;
  private refreshPromise: Promise<any> | null = null;

  constructor() {
    this.isLoggedIn = signal(this.hasValidToken());
    this.loadFromStorage();
  }

  private loadFromStorage(): void {
    try {
      const rolesData = localStorage.getItem(this.ROLES_KEY);
      if (rolesData) {
        this.rolesSignal.set(JSON.parse(rolesData));
      }
    } catch {
      this.rolesSignal.set([]);
    }
  }

  storeLoginResponse(loginResponse: LoginResponse): void {
    if (!loginResponse.token) return;

    if (loginResponse.token.accessToken) {
      localStorage.setItem(this.ACCESS_TOKEN_KEY, loginResponse.token.accessToken);
    }
    if (loginResponse.token.refreshToken) {
      localStorage.setItem(this.REFRESH_TOKEN_KEY, loginResponse.token.refreshToken);
    }
    if (loginResponse.token.refreshTokenExpiresAt) {
      localStorage.setItem(this.REFRESH_TOKEN_EXP_KEY, new Date(loginResponse.token.refreshTokenExpiresAt).toISOString());
    }

    if (loginResponse.user) {
      localStorage.setItem(this.USER_DATA_KEY, JSON.stringify(loginResponse.user));
      const roles = loginResponse.user.roles || [];
      localStorage.setItem(this.ROLES_KEY, JSON.stringify(roles));
      this.rolesSignal.set(roles);
    }

    this.isLoggedIn.set(true);
  }

  storeUserData(user: UserDto): void {
    if (user) {
      localStorage.setItem(this.USER_DATA_KEY, JSON.stringify(user));
      const roles = user.roles || [];
      localStorage.setItem(this.ROLES_KEY, JSON.stringify(roles));
      this.rolesSignal.set(roles);
    }
  }

  getToken(): string | null {
    return localStorage.getItem(this.ACCESS_TOKEN_KEY);
  }

  getRefreshToken(): string | null {
    return localStorage.getItem(this.REFRESH_TOKEN_KEY);
  }

  getUserData(): UserDto | null {
    const userData = localStorage.getItem(this.USER_DATA_KEY);
    if (!userData) return null;
    try {
      return JSON.parse(userData) as UserDto;
    } catch (error) {
      this.toast.showError('Error parsing user data');
      return null;
    }
  }

  hasValidToken(): boolean {
    const token = this.getToken();
    if (!token) return false;
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Math.floor(Date.now() / 1000);
      return payload.exp > currentTime;
    } catch {
      return false;
    }
  }

  hasValidRefreshToken(): boolean {
    const expDate = localStorage.getItem(this.REFRESH_TOKEN_EXP_KEY);
    if (!expDate) return false;
    return new Date() < new Date(expDate);
  }

  refreshTokens(): Observable<any> {
    if (!this.hasValidRefreshToken()) {
      return throwError(() => new Error('No valid refresh token available'));
    }

    if (this.isRefreshing && this.refreshPromise) {
      return new Observable(observer => {
        this.refreshPromise!
          .then(response => {
            observer.next(response);
            observer.complete();
          })
          .catch(err => observer.error(err));
      });
    }

    this.isRefreshing = true;
    const refreshToken = this.getRefreshToken() || '';

    this.refreshPromise = new Promise((resolve, reject) => {
      this.http.post<any>(`${environment.apiUrl}/api/account/refresh-token`, { refreshToken }).pipe(
        tap((response: any) => {
          if (response && response.success) {
            this.storeLoginResponse(response);
            this.isRefreshing = false;
            this.refreshPromise = null;
            resolve(response);
          } else {
            this.logout();
            reject(new Error('Refresh token invalid'));
          }
        }),
        catchError(error => {
          this.isRefreshing = false;
          this.refreshPromise = null;
          this.logout();
          reject(error);
          return throwError(() => error);
        })
      ).subscribe();
    });

    return new Observable(observer => {
      this.refreshPromise!
        .then(response => {
          observer.next(response);
          observer.complete();
        })
        .catch(err => observer.error(err));
    });
  }

  removeAuthData(): void {
    localStorage.removeItem(this.ACCESS_TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_TOKEN_EXP_KEY);
    localStorage.removeItem(this.USER_DATA_KEY);
    localStorage.removeItem(this.ROLES_KEY);
    this.rolesSignal.set([]);
    this.isLoggedIn.set(false);
  }

  logout(): void {
    const refreshToken = this.getRefreshToken() || '';
    if (refreshToken) {
      this.http.post(`${environment.apiUrl}/api/account/logout`, { refreshToken }).pipe(
        catchError(() => throwError(() => new Error('Logout failed')))
      ).subscribe();
    }

    this.removeAuthData();
    this.router.navigate(['/login']);
  }

  isAuthenticated(): boolean {
    return this.isLoggedIn();
  }

  getCurrentUserId(): number | null {
    return this.getUserData()?.id || null;
  }

  getCurrentUserEmail(): string | null {
    return this.getUserData()?.email || null;
  }

  getCurrentUserFirstName(): string | null {
    return this.getUserData()?.firstName || null;
  }

  hasRole(role: string): boolean {
    return this.roles().includes(role);
  }

  isSuperAdmin(): boolean {
    return this.hasRole('SuperAdmin');
  }

  // Implementation of permission check (TODO: implement granular permissions when available in API)
  hasPermission(permission: any): boolean {
    if (this.isSuperAdmin()) return true;
    return false;
  }
}
