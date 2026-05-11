import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatChipsModule } from '@angular/material/chips';
import { MatTabsModule } from '@angular/material/tabs';
import { MatCardModule } from '@angular/material/card';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { AdminClient, IAdminUserDto, UpdateUserStatusCommand } from '../../../core/api/api-client';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { AuthService } from '../../../core/services/auth.service';
import { ToastService } from '../../../shared/services/toast.service';
import { PermissionService } from '../../../core/services/permission.service';
import { PermissionType } from '../../../core/constants/permissions';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { CreateUserDialogComponent } from '../../admin/user-management/create-user-dialog/create-user-dialog';

@Component({
  selector: 'app-staff-management',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatSlideToggleModule,
    MatChipsModule,
    MatTabsModule,
    MatCardModule,
    MatPaginatorModule,
    MatDialogModule,
    MatTooltipModule,
    TranslateModule,
    HeaderSectionComponent,
  ],
  templateUrl: './staff-management.html',
  styleUrl: './staff-management.scss',
})
export class StaffManagementComponent implements OnInit {
  private adminClient = inject(AdminClient);
  private authService = inject(AuthService);
  private toast = inject(ToastService);
  private dialog = inject(MatDialog);
  private permissionService = inject(PermissionService);
  private translate = inject(TranslateService);

  allUsers = signal<IAdminUserDto[]>([]);
  totalUsers = signal(0);
  pageSize = signal(20);
  pageIndex = signal(0);
  isLoading = signal(true);
  searchTerm = signal<string | null>(null);
  error = signal<string | null>(null);
  activeTabIndex = signal(0);

  canCreateStaff = computed(() => this.authService.isSuperAdmin());
  canEditStaff = computed(() => this.authService.isSuperAdmin());

  displayedColumns: string[] = ['name', 'email', 'roles', 'status', 'actions'];

  // Tabs config
  tabs = [
    { label: 'superAdmin.allStaff', role: null },
    { label: 'superAdmin.admins', role: 'Admin' },
    { label: 'superAdmin.supportAgents', role: 'Support' },
    { label: 'superAdmin.experts', role: 'Expert' },
  ];

  // Filtered users based on active tab
  filteredUsers = computed(() => {
    const tab = this.tabs[this.activeTabIndex()];
    const users = this.allUsers();
    if (!tab.role) {
      // "All Staff" tab: only show users with staff roles (Admin, Support, Expert)
      return users.filter(u => u.roles?.some(r =>
        ['admin', 'support', 'expert', 'superadmin'].includes(r.toLowerCase())
      ));
    }
    return users.filter(u => u.roles?.some(r => r.toLowerCase() === tab.role!.toLowerCase()));
  });

  ngOnInit(): void {
    this.loadUsers();
  }

  onSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchTerm.set(input.value || null);
    this.pageIndex.set(0);
    this.loadUsers();
  }

  onTabChange(index: number): void {
    this.activeTabIndex.set(index);
  }

  loadUsers(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getAdminUsers(this.pageIndex() + 1, this.pageSize(), this.searchTerm() ?? undefined)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (!response.error && response.data) {
            this.allUsers.set(response.data.users || []);
            this.totalUsers.set(response.data.total || 0);
          } else {
            this.error.set(response.messages?.[0] || 'Failed to load staff');
          }
        },
        error: (err) => {
          this.error.set('An error occurred while fetching staff data');
          console.error('Staff Load Error:', err);
        },
      });
  }

  addStaff(): void {
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
    const command = new UpdateUserStatusCommand({
      userId: user.id,
      isActive: newStatus,
    });

    this.adminClient.updateUserStatus(user.id, command).subscribe({
      next: (response) => {
        if (!response.error) {
          user.isActive = newStatus;
          this.toast.showSuccess(this.translate.instant('superAdmin.toast.statusUpdated'));
        } else {
          this.toast.showError(response.messages?.[0] || 'Failed to update status');
        }
      },
      error: () => {
        this.toast.showError(this.translate.instant('superAdmin.toast.permissionError'));
      },
    });
  }

  editRoles(user: IAdminUserDto): void {
    import('../../admin/user-management/assign-role-dialog/assign-role-dialog.component').then(m => {
      const dialogRef = this.dialog.open(m.AssignRoleDialogComponent, {
        width: '400px',
        data: { user }
      });

      dialogRef.afterClosed().subscribe(newRoles => {
        if (newRoles) {
          user.roles = newRoles;
          this.toast.showSuccess(this.translate.instant('superAdmin.toast.rolesUpdated'));
        }
      });
    });
  }

  getInitials(user: IAdminUserDto): string {
    const first = user.firstName?.charAt(0) || '';
    const last = user.lastName?.charAt(0) || '';
    return (first + last).toUpperCase();
  }

  getAvatarColor(user: IAdminUserDto): string {
    const colors = ['#6366f1', '#8b5cf6', '#ec4899', '#f43f5e', '#f59e0b', '#10b981', '#3b82f6'];
    const index = (user.id || 0) % colors.length;
    return colors[index];
  }

  getTabCount(role: string | null): number {
    const users = this.allUsers();
    if (!role) {
      return users.filter(u => u.roles?.some(r =>
        ['admin', 'support', 'expert', 'superadmin'].includes(r.toLowerCase())
      )).length;
    }
    return users.filter(u => u.roles?.some(r => r.toLowerCase() === role.toLowerCase())).length;
  }
}
