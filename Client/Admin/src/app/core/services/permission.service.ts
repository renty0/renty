import { inject, Injectable, signal, computed, effect, untracked } from '@angular/core';
import { AuthClient } from '../api/api-client';
import { AuthService } from './auth.service';
import { catchError, map, Observable, of, tap } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class PermissionService {
  private readonly authClient = inject(AuthClient);
  private readonly authService = inject(AuthService);

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
    return this.authClient.authMe().pipe(
      map((res) => res?.data?.permissions || []),
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
