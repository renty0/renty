import { computed, inject, Injectable, signal, WritableSignal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';
import { ToastService } from '../../shared/services/toast.service';
import { LoginResponse, UserDto, AccountClient, RefreshTokenCommand } from '../api/api-client';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { CookieService } from 'ngx-cookie-service';
import * as CryptoJS from 'crypto-js';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly toast = inject(ToastService);
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly cookieService = inject(CookieService);

  private readonly ENCRYPTION_KEY = 'renty-auth-secure-key-2026';
  private readonly ACCESS_TOKEN_KEY = 'atk';
  private readonly REFRESH_TOKEN_KEY = 'rtk';
  private readonly REFRESH_TOKEN_EXP_KEY = 'rtek';
  private readonly USER_DATA_KEY = 'udk';
  private readonly ROLES_KEY = 'urk';

  isLoggedIn: WritableSignal<boolean>;
  private readonly rolesSignal = signal<string[]>([]);
  readonly roles = computed(() => this.rolesSignal());

  private isRefreshing = false;
  private refreshPromise: Promise<any> | null = null;

  constructor() {
    this.isLoggedIn = signal(this.hasValidToken());
    this.loadFromStorage();
  }

  private encrypt(data: string): string {
    return CryptoJS.AES.encrypt(data, this.ENCRYPTION_KEY).toString();
  }

  private decrypt(ciphertext: string): string {
    try {
      const bytes = CryptoJS.AES.decrypt(ciphertext, this.ENCRYPTION_KEY);
      return bytes.toString(CryptoJS.enc.Utf8);
    } catch {
      return '';
    }
  }

  private setSecureCookie(key: string, value: string, expires?: number | Date): void {
    const encrypted = this.encrypt(value);
    this.cookieService.set(key, encrypted, {
      expires: expires,
      path: '/',
      secure: true,
      sameSite: 'Lax'
    });
  }

  private getSecureCookie(key: string): string | null {
    const encrypted = this.cookieService.get(key);
    if (!encrypted) return null;
    const decrypted = this.decrypt(encrypted);
    return decrypted || null;
  }

  private loadFromStorage(): void {
    try {
      const rolesData = this.getSecureCookie(this.ROLES_KEY);
      if (rolesData) {
        this.rolesSignal.set(JSON.parse(rolesData));
      }
    } catch {
      this.rolesSignal.set([]);
    }
  }

  storeLoginResponse(loginResponse: LoginResponse): void {
    if (!loginResponse.token) return;

    // Use token expiration for cookie expiration if available, otherwise fallback to 7 days
    const expires = loginResponse.token.refreshTokenExpiresAt ?
      new Date(loginResponse.token.refreshTokenExpiresAt) : 7;

    if (loginResponse.token.accessToken) {
      this.setSecureCookie(this.ACCESS_TOKEN_KEY, loginResponse.token.accessToken, expires);
    }
    if (loginResponse.token.refreshToken) {
      this.setSecureCookie(this.REFRESH_TOKEN_KEY, loginResponse.token.refreshToken, expires);
    }
    if (loginResponse.token.refreshTokenExpiresAt) {
      this.setSecureCookie(this.REFRESH_TOKEN_EXP_KEY, new Date(loginResponse.token.refreshTokenExpiresAt).toISOString(), expires);
    }

    if (loginResponse.user) {
      const userData = JSON.stringify(loginResponse.user);
      this.setSecureCookie(this.USER_DATA_KEY, userData, expires);
      const roles = loginResponse.user.roles || [];
      this.setSecureCookie(this.ROLES_KEY, JSON.stringify(roles), expires);
      this.rolesSignal.set(roles);
    }

    this.isLoggedIn.set(true);
  }

  storeUserData(user: UserDto): void {
    if (user) {
      const userData = JSON.stringify(user);
      this.setSecureCookie(this.USER_DATA_KEY, userData, 7);
      const roles = user.roles || [];
      this.setSecureCookie(this.ROLES_KEY, JSON.stringify(roles), 7);
      this.rolesSignal.set(roles);
    }
  }

  getToken(): string | null {
    return this.getSecureCookie(this.ACCESS_TOKEN_KEY);
  }

  getRefreshToken(): string | null {
    return this.getSecureCookie(this.REFRESH_TOKEN_KEY);
  }

  getUserData(): UserDto | null {
    const userData = this.getSecureCookie(this.USER_DATA_KEY);
    if (!userData) return null;
    try {
      return JSON.parse(userData) as UserDto;
    } catch (error) {
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
    const expDate = this.getSecureCookie(this.REFRESH_TOKEN_EXP_KEY);
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
    this.cookieService.delete(this.ACCESS_TOKEN_KEY, '/');
    this.cookieService.delete(this.REFRESH_TOKEN_KEY, '/');
    this.cookieService.delete(this.REFRESH_TOKEN_EXP_KEY, '/');
    this.cookieService.delete(this.USER_DATA_KEY, '/');
    this.cookieService.delete(this.ROLES_KEY, '/');
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

  isAdmin(): boolean {
    return this.hasRole('Admin');
  }

  isSuperAdmin(): boolean {
    return this.isAdmin();
  }

  hasPermission(permission: any): boolean {
    if (this.isSuperAdmin()) return true;
    return false;
  }
}
