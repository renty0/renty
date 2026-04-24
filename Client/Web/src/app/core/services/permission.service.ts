import { inject, Injectable, signal, computed, effect, untracked } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AuthService } from './auth.service';
import { catchError, map, Observable, of, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class PermissionService {
  private readonly http = inject(HttpClient);
  private readonly authService = inject(AuthService);
  private readonly baseUrl = environment.apiUrl;

  private readonly permissionsSignal = signal<string[]>([]);
  readonly permissions = computed(() => {
    const authPerms = this.authService.permissions();
    return authPerms.length > 0 ? authPerms : this.permissionsSignal();
  });

  constructor() {
    // Sync with auth service permissions
    effect(() => {
      const authPerms = this.authService.permissions();
      if (authPerms.length > 0) {
        untracked(() => this.permissionsSignal.set(authPerms));
      }
    });
  }

  fetchPermissions(): Observable<string[]> {
    return this.http.get<{ data: string[] }>(`${this.baseUrl}/api/account/permissions`).pipe(
      map((res) => res.data || []),
      tap((perms) => this.permissionsSignal.set(perms)),
      catchError(() => {
        this.permissionsSignal.set([]);
        return of([]);
      })
    );
  }

  hasPermission(permission: string): boolean {
    if (this.authService.isSuperAdmin()) return true;
    return this.permissions().includes(permission);
  }

  hasAnyPermission(requiredPermissions: string[]): boolean {
    if (this.authService.isSuperAdmin()) return true;
    return requiredPermissions.some((p) => this.permissions().includes(p));
  }

  hasAllPermissions(requiredPermissions: string[]): boolean {
    if (this.authService.isSuperAdmin()) return true;
    return requiredPermissions.every((p) => this.permissions().includes(p));
  }
}
