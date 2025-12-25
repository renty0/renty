import { inject, Injectable, signal, WritableSignal } from '@angular/core';
import { Router } from '@angular/router';
import { ToastService } from '../../shared/services/toast.service';
// import { UserSessionDto } from '../../../../api-client';
// import { SnackBarService } from '../../shared/services/snackbar/snack-bar.service';
interface UserSessionDto {}
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private toast = inject(ToastService);
  private readonly TOKEN_KEY = 'access_token';
  private readonly USER_DATA_KEY = 'user_data';
  private readonly REFRESH_TOKEN_EXP_KEY = 'refresh_token_exp';

  private router = inject(Router);
  isLoggedIn: WritableSignal<boolean>;

  constructor() {
    this.isLoggedIn = signal(this.hasValidToken());
  }

  storeLoginResponse(
    loginResponse: any
    // loginResponse: UserSessionDto
  ): void {
    if (!loginResponse.accessToken || !loginResponse.accessTokenExpDate) return;
    this.setCookie(this.TOKEN_KEY, loginResponse.accessToken, new Date(loginResponse.accessTokenExpDate));
    const userData = {
      userId: loginResponse.userId,
      firstName: loginResponse.firstName,
      email: loginResponse.email,
      imageUrl: loginResponse.imageUrl,
      adminPermissions: loginResponse.adminPermissions,
      entityPermissions: loginResponse.entityPermissions
    };
    this.setCookie(this.USER_DATA_KEY, JSON.stringify(userData), new Date(loginResponse.accessTokenExpDate));
    if (!loginResponse.refreshTokenExpDate || !loginResponse.refreshTokenExpDate) return;
    this.setCookie(this.REFRESH_TOKEN_EXP_KEY, String(loginResponse.refreshTokenExpDate), new Date(loginResponse.refreshTokenExpDate));
    this.isLoggedIn.set(true);
  }
  private setCookie(name: string, value: string, expires: Date): void {
    const cookieString = `${name}=${encodeURIComponent(value)}; expires=${expires.toUTCString()}; path=/; SameSite=Strict; Secure`;
    document.cookie = cookieString;
  }
  private getCookie(name: string): string | null {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) === ' ') c = c.substring(1, c.length);
      if (c.indexOf(nameEQ) === 0) {
        return decodeURIComponent(c.substring(nameEQ.length, c.length));
      }
    }
    return null;
  }
  private deleteCookie(name: string): void {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
  }
  getToken(): string | null {
    return this.getCookie(this.TOKEN_KEY);
  }
  // getUserData(): Partial<UserSessionDto> | null {
  getUserData(): Partial<any> | null {
    const userData = this.getCookie(this.USER_DATA_KEY);
    if (!userData) return null;
    try {
      return JSON.parse(userData);
    } catch (error) {
      this.toast.showError('Error parsing user data from cookie');
      return null;
    }
  }
  getRefreshTokenExpDate(): Date | null {
    const expDate = this.getCookie(this.REFRESH_TOKEN_EXP_KEY);
    return expDate ? new Date(expDate) : null;
  }
  hasValidToken(): boolean {
    const token = this.getToken();
    if (!token) return false;
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Math.floor(Date.now() / 1000);
      return payload.exp > currentTime;
    } catch (error) {
      this.toast.showError('Error parsing token');
      return false;
    }
  }
  hasValidRefreshToken(): boolean {
    const refreshExpDate = this.getRefreshTokenExpDate();
    if (!refreshExpDate) return false;
    return new Date() < refreshExpDate;
  }
  removeAuthData(): void {
    this.deleteCookie(this.TOKEN_KEY);
    this.deleteCookie(this.USER_DATA_KEY);
    this.deleteCookie(this.REFRESH_TOKEN_EXP_KEY);
    this.isLoggedIn.set(false);
  }
  getAuthorizationHeader(): string | null {
    const token = this.getToken();
    return token ? `Bearer ${token}` : null;
  }
  logout(): void {
    this.removeAuthData();
    this.router.navigate(['/login']);
  }
  isAuthenticated(): boolean {
    return this.isLoggedIn();
  }
  getCurrentUserId(): number | null {
    const userData = this.getUserData();
    // return userData?.userId || null;
    return null;
  }
  getCurrentUserEmail(): string | null {
    const userData = this.getUserData();
    // return userData?.email || null;
    return null;
  }
  getCurrentUserFirstName(): string | null {
    const userData = this.getUserData();
    // return userData?.firstName || null;
    return null;
  }
  hasAdminPermission(permission: number): boolean {
    const userData = this.getUserData();
    // return userData?.adminPermissions?.includes(permission) || false;
    return false;
  }
  hasEntityPermission(permission: number): boolean {
    const userData = this.getUserData();
    // return userData?.entityPermissions?.includes(permission) || false;
    return false;
  }
  getAdminPermissions(): number[] {
    const userData = this.getUserData();
    // return userData?.adminPermissions || [];
    return [];
  }
  getEntityPermissions(): number[] {
    const userData = this.getUserData();
    // return userData?.entityPermissions || [];
    return [];
  }
}
