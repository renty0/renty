import { Component, inject, OnInit, signal, computed, DestroyRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialogModule } from '@angular/material/dialog';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatTooltipModule } from '@angular/material/tooltip';
import { TranslateModule } from '@ngx-translate/core';
import { rxResource, takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Subject, debounceTime, distinctUntilChanged, exhaustMap, tap, catchError, of, finalize } from 'rxjs';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { AdminClient, RoleDto, PermissionMetadataDto, UpdateRoleCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { PermissionService } from '../../../core/services/permission.service';

@Component({
  selector: 'app-role-management',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatChipsModule,
    MatProgressBarModule,
    MatCardModule,
    MatDialogModule,
    MatCheckboxModule,
    MatProgressSpinnerModule,
    LoadingButtonComponent,
    MatTooltipModule,
    HeaderSectionComponent,
    TranslateModule
  ],
  templateUrl: './role-management.html',
  styleUrl: './role-management.scss',
})
export class RoleManagementComponent {
  private readonly rolesClient = inject(AdminClient);
  private readonly toast = inject(ToastService);
  public readonly permissionService = inject(PermissionService);

  private readonly searchSubject = new Subject<string>();
  private readonly saveSubject = new Subject<void>();
  
  searchTerm = signal('');
  selectedRole = signal<RoleDto | null>(null);
  selectedRolePermissions = signal<string[]>([]);
  isSaving = signal(false);

  rolesResource = rxResource({
    params: () => ({ search: this.searchTerm() }),
    stream: () => this.rolesClient.getAdminRoles()
  });

  availablePermissionsResource = rxResource({
    stream: () => this.rolesClient.getAvailablePermissions()
  });

  displayedColumns: string[] = ['name', 'userCount', 'actions'];
  skeletonData = [1, 2, 3, 4, 5];

  roles = computed(() => {
    const all = this.rolesResource.value()?.data || [];
    const search = this.searchTerm().toLowerCase();
    if (!search) return all;
    return all.filter(r => r.name?.toLowerCase().includes(search));
  });
  isLoading = computed(() => this.rolesResource.isLoading());
  
  groupedPermissions = computed(() => {
    return this.availablePermissionsResource.value()?.data || [];
  });

  modules = computed(() => this.groupedPermissions().map(g => g.module || ''));

  constructor() {
    this.searchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      takeUntilDestroyed()
    ).subscribe(value => this.searchTerm.set(value));

    this.saveSubject.pipe(
      tap(() => this.isSaving.set(true)),
      exhaustMap(() => {
        const role = this.selectedRole();
        if (!role?.id) return of(null);
        
        return this.rolesClient.updateRole(
          role.id, 
          new UpdateRoleCommand({
            id: role.id,
            name: role.name,
            permissions: this.selectedRolePermissions()
          })
        ).pipe(
          tap(() => {
            this.toast.showSuccess('Permissions updated successfully');
            this.selectedRole.set(null);
            this.rolesResource.reload();
          }),
          catchError(() => {
            this.toast.showError('Failed to update permissions');
            return of(null);
          }),
          finalize(() => this.isSaving.set(false))
        );
      }),
      takeUntilDestroyed()
    ).subscribe();
  }

  onSearch(event: any): void {
    const value = typeof event === 'string' ? event : event?.target?.value || '';
    this.searchSubject.next(value);
  }

  editPermissions(role: RoleDto): void {
    if (role.name === 'SuperAdmin' || !role.id) return;
    
    this.selectedRole.set(role);
    this.rolesClient.getRoleDetails(role.id).subscribe({
      next: (response) => this.selectedRolePermissions.set(response.data?.permissions || []),
      error: () => this.toast.showError('Failed to load permissions for role')
    });
  }

  isPermissionSelected(permValue: string | undefined): boolean {
    if (!permValue) return false;
    return this.selectedRolePermissions().includes(permValue);
  }

  togglePermission(permValue: string | undefined): void {
    if (!permValue) return;
    this.selectedRolePermissions.update(current => 
      current.includes(permValue) 
        ? current.filter(p => p !== permValue) 
        : [...current, permValue]
    );
  }

  savePermissions(): void {
    this.saveSubject.next();
  }

  getPermissionsByModule(module: string) {
    const group = this.groupedPermissions().find(g => g.module === module);
    return group?.permissions || [];
  }
}

