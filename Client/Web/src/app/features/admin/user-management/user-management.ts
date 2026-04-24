import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatChipsModule } from '@angular/material/chips';
import { AdminClient, IAdminUserDto, UpdateUserStatusCommand } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { AuthService } from '../../../core/services/auth.service';
import { ToastService } from '../../../shared/services/toast.service';
import { MatCardModule } from '@angular/material/card';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { CreateUserDialogComponent } from './create-user-dialog/create-user-dialog';
import { PermissionService } from '../../../core/services/permission.service';
import { PermissionType } from '../../../core/constants/permissions';

@Component({
  selector: 'app-user-management',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatSlideToggleModule,
    MatChipsModule,
    MatPaginatorModule,
    MatCardModule,
    HeaderSectionComponent,
    TranslateModule,
    MatDialogModule,
  ],
  templateUrl: './user-management.html',
  styleUrl: './user-management.scss',
})
export class UserManagementComponent implements OnInit {
  private adminClient = inject(AdminClient);
  private authService = inject(AuthService);
  private toast = inject(ToastService);
  private dialog = inject(MatDialog);
  private permissionService = inject(PermissionService);

  users = signal<IAdminUserDto[]>([]);
  totalUsers = signal(0);
  pageSize = signal(20);
  pageIndex = signal(0);
  isLoading = signal(true);
  searchTerm = signal<string | null>(null);
  error = signal<string | null>(null);

  canAddUsers = computed(() => this.permissionService.hasPermission(PermissionType.Users_Create));
  canEditUsers = computed(() => this.permissionService.hasPermission(PermissionType.Users_Edit));

  displayedColumns: string[] = ['name', 'email', 'role', 'status', 'actions'];

  ngOnInit(): void {
    this.loadUsers();
  }

  onSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchTerm.set(input.value || null);
    this.pageIndex.set(0);
    this.loadUsers();
  }

  loadUsers(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getAdminUsers(this.pageIndex() + 1, this.pageSize(), this.searchTerm() ?? undefined).subscribe({
      next: (response: any) => {
        if (response && response.data) {
          this.users.set(response.data.users || []);
          this.totalUsers.set(response.data.total || 0);
        } else {
          this.error.set(response?.error || 'Failed to load users');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.error.set('An error occurred while fetching users');
        this.isLoading.set(false);
        console.error('User Load Error:', err);
      },
    });
  }

  addUser(): void {
    const dialogRef = this.dialog.open(CreateUserDialogComponent, {
      width: '500px',
    });

    dialogRef.afterClosed().subscribe((result) => {
      if (result) {
        this.loadUsers();
      }
    });
  }

  onPageChange(event: PageEvent): void {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
    this.loadUsers();
  }

  toggleUserStatus(user: IAdminUserDto): void {
    if (user.id === undefined) return;

    const newStatus = !user.isActive;
    const command = UpdateUserStatusCommand.fromJS({
      userId: user.id,
      isActive: newStatus,
    });

    this.adminClient.updateUserStatus(user.id, command).subscribe({
      next: (response: any) => {
        if (response && response.success) {
          user.isActive = newStatus;
          this.toast.showSuccess(`User ${newStatus ? 'activated' : 'deactivated'} successfully`);
        } else {
          this.toast.showError(response?.error || 'Failed to update user status');
        }
      },
      error: (err) => {
        this.toast.showError('An error occurred. Check if you have SuperAdmin permissions.');
        console.error('Update User Status Error:', err);
      },
    });
  }

  getRoleColor(role: string): string {
    switch (role?.toLowerCase()) {
      case 'superadmin':
        return 'warn';
      case 'admin':
        return 'accent';
      case 'support':
        return 'primary';
      case 'expert':
        return 'primary';
      default:
        return '';
    }
  }

  getInitials(user: IAdminUserDto): string {
    const first = user.firstName?.charAt(0) || '';
    const last = user.lastName?.charAt(0) || '';
    return (first + last).toUpperCase();
  }

  getAvatarColor(user: IAdminUserDto): string {
    const colors = [
      '#6366f1', // Indigo
      '#8b5cf6', // Violet
      '#ec4899', // Pink
      '#f43f5e', // Rose
      '#f59e0b', // Amber
      '#10b981', // Emerald
      '#3b82f6', // Blue
    ];
    const index = (user.id || 0) % colors.length;
    return colors[index];
  }

  editRoles(user: IAdminUserDto): void {
    import('./assign-role-dialog/assign-role-dialog.component').then(m => {
      const dialogRef = this.dialog.open(m.AssignRoleDialogComponent, {
        width: '400px',
        data: { user }
      });

      dialogRef.afterClosed().subscribe(newRoles => {
        if (newRoles) {
          user.roles = newRoles;
          this.toast.showSuccess('Roles updated successfully');
        }
      });
    });
  }
}
