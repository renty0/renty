import { Component, inject, OnInit, signal } from '@angular/core';
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
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressBar } from '@angular/material/progress-bar';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';

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
    MatProgressBar,
    HeaderSectionComponent,
    TranslateModule,
    MatSnackBarModule,
  ],
  templateUrl: './user-management.html',
  styleUrl: './user-management.scss',
})
export class UserManagementComponent implements OnInit {
  private adminClient = inject(AdminClient);
  private authService = inject(AuthService);
  private snackBar = inject(MatSnackBar);

  users = signal<IAdminUserDto[]>([]);
  totalUsers = signal(0);
  pageSize = signal(20);
  pageIndex = signal(0);
  isLoading = signal(true);
  error = signal<string | null>(null);

  isSuperAdmin = this.authService.isAdmin();

  displayedColumns: string[] = ['name', 'email', 'role', 'status', 'actions'];

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getAdminUsers(this.pageIndex() + 1, this.pageSize()).subscribe({
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
          this.snackBar.open(
            `User ${newStatus ? 'activated' : 'deactivated'} successfully`,
            'Close',
            { duration: 3000 },
          );
        } else {
          this.snackBar.open(response?.error || 'Failed to update user status', 'Close', {
            duration: 3000,
          });
        }
      },
      error: (err) => {
        this.snackBar.open(
          'An error occurred. Check if you have SuperAdmin permissions.',
          'Close',
          { duration: 5000 },
        );
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
}
