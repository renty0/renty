import { computed, inject, Injectable, signal, WritableSignal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, throwError, catchError, map, tap } from 'rxjs';
import {
  ApiResponseOfAuthLoginData,
  ApiResponseOfAuthRefreshData,
  ApiResponseOfAuthRegisterData,
  ApiResponseOfAuthVerifyEmailData,
  AuthClient,
  AuthLoginData,
  AuthLoginUser,
  AuthRefreshData,
  ConfirmEmailCommand,
  LoginCommand,
  RefreshTokenCommand,
  RegisterCommand,
} from '../api/api-client';
import { CookieService } from 'ngx-cookie-service';
import * as CryptoJS from 'crypto-js';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly authClient = inject(AuthClient);
  private readonly router = inject(Router);
  private readonly cookieService = inject(CookieService);

  private readonly ENCRYPTION_KEY = 'renty-auth-secure-key-2026';
  private readonly ACCESS_TOKEN_KEY = 'atk';
  private readonly REFRESH_TOKEN_KEY = 'rtk';
  private readonly REFRESH_TOKEN_EXP_KEY = 'rtek';
  private readonly USER_DATA_KEY = 'udk';
  private readonly ROLES_KEY = 'urk';

  isLoggedIn: WritableSignal<boolean>;
  private readonly rolesSignal = signal<string>('user');
  readonly roles = computed(() => this.rolesSignal());

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
      sameSite: 'Lax',
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
      this.rolesSignal.set('user');
    }
  }

  storeLoginResponse(loginResponse: AuthLoginData): void {
    if (!loginResponse.accessToken) return;

    // Use token expiration for cookie expiration if available, otherwise fallback to 7 days
    const expires = 7;
    loginResponse.refreshTokenExpiresAt ?
      new Date(loginResponse.refreshTokenExpiresAt) : 7;

    if (loginResponse.accessToken) {
      this.setSecureCookie(this.ACCESS_TOKEN_KEY, loginResponse.accessToken, expires);
    }
    if (loginResponse.refreshToken) {
      this.setSecureCookie(this.REFRESH_TOKEN_KEY, loginResponse.refreshToken, expires);
    }
    if (loginResponse.refreshTokenExpiresAt) {
      this.setSecureCookie(this.REFRESH_TOKEN_EXP_KEY, new Date(loginResponse.refreshTokenExpiresAt).toISOString(), expires);
    }

    if (loginResponse.user) {
      const userData = JSON.stringify(loginResponse.user);
      this.setSecureCookie(this.USER_DATA_KEY, userData, expires);
      const roles = loginResponse.user.role || 'user';
      this.setSecureCookie(this.ROLES_KEY, JSON.stringify(roles), expires);
      this.rolesSignal.set(roles);
    }

    this.isLoggedIn.set(true);
  }

  login(email: string, password: string): Observable<ApiResponseOfAuthLoginData> {
    const command = new LoginCommand({
      email,
      password,
    });

    return this.authClient.authLogin(command).pipe(
      tap((response: ApiResponseOfAuthLoginData) => {
        if (response.success && response.data) {
          this.storeLoginResponse(response.data);
        }
      }),
    );
  }

  register(payload: {
    email: string;
    password: string;
    confirmPassword: string;
    firstName: string;
    lastName: string;
    phoneNumber?: string;
    address?: string;
    city?: string;
    country?: string;
    bio?: string;
    userType: any;
  }): Observable<ApiResponseOfAuthRegisterData> {
    const command = new RegisterCommand({
      email: payload.email,
      password: payload.password,
      confirmPassword: payload.confirmPassword,
      firstName: payload.firstName,
      lastName: payload.lastName,
      phoneNumber: payload.phoneNumber || undefined,
      address: payload.address || undefined,
      city: payload.city || undefined,
      country: payload.country || undefined,
      bio: payload.bio || undefined,
      userType: payload.userType,
    });

    return this.authClient.authRegister(command);
  }

  verifyEmail(email: string, code: string): Observable<ApiResponseOfAuthVerifyEmailData> {
    const command = new ConfirmEmailCommand({ email, code });
    return this.authClient.authVerifyEmail(command);
  }

  storeUserData(user: AuthLoginUser): void {
    if (user) {
      const userData = JSON.stringify(user);
      this.setSecureCookie(this.USER_DATA_KEY, userData, 7);
      const roles = user.role || 'user';
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

  getUserData(): AuthLoginUser | null {
    const userData = this.getSecureCookie(this.USER_DATA_KEY);
    if (!userData) return null;
    try {
      return JSON.parse(userData) as AuthLoginUser;
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
    return !!this.getRefreshToken();
  }

  refreshTokens(): Observable<any> {
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) {
      return throwError(() => new Error('No refresh token available'));
    }

    const command = new RefreshTokenCommand({
      refreshToken,
    });

    return this.authClient.authRefresh(command).pipe(
      tap((response: ApiResponseOfAuthRefreshData) => {
        if (response.success && response.data) {
          const data: AuthRefreshData = response.data;
          const expires = 7;

          if (data.accessToken) {
            this.setSecureCookie(this.ACCESS_TOKEN_KEY, data.accessToken, expires);
          }

          if (data.refreshToken) {
            this.setSecureCookie(this.REFRESH_TOKEN_KEY, data.refreshToken, expires);
          }

          this.isLoggedIn.set(true);
        } else {
          this.logout();
        }
      }),
      map((response: ApiResponseOfAuthRefreshData) => {
        if (!response.data) {
          throw new Error('No data in refresh response');
        }

        return response.data;
      }),
      catchError((error: any) => {
        this.logout();
        return throwError(() => error);
      }),
    );
  }

  removeAuthData(): void {
    this.cookieService.delete(this.ACCESS_TOKEN_KEY, '/');
    this.cookieService.delete(this.REFRESH_TOKEN_KEY, '/');
    this.cookieService.delete(this.REFRESH_TOKEN_EXP_KEY, '/');
    this.cookieService.delete(this.USER_DATA_KEY, '/');
    this.cookieService.delete(this.ROLES_KEY, '/');
    this.rolesSignal.set('user');
    this.isLoggedIn.set(false);
  }

  logout(): void {
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
