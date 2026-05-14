import { Component, Inject, OnInit, signal } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { AdminClient, AssignUserRolesCommand, IAdminUserDto, RoleDto } from '../../../../core/api/api-client';

@Component({
  selector: 'app-assign-role-dialog',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatDialogModule,
    MatButtonModule,
    MatCheckboxModule,
    MatProgressSpinnerModule,
    MatIconModule,
    TranslateModule,
    LoadingButtonComponent
  ],
  templateUrl: './assign-role-dialog.component.html',
  styleUrl: './assign-role-dialog.component.scss'
})
export class AssignRoleDialogComponent implements OnInit {
  availableRoles = signal<RoleDto[]>([]);
  selectedRoles = signal<string[]>([]);
  loading = signal(true);
  saving = signal(false);
  error = signal<string | null>(null);

  constructor(
    public dialogRef: MatDialogRef<AssignRoleDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { user: IAdminUserDto },
    private adminClient: AdminClient
  ) {
    this.selectedRoles.set([...(data.user.roles || [])]);
  }

  ngOnInit() {
    this.adminClient.getAdminRoles()
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error) {
            this.availableRoles.set(res.data || []);
          } else {
            this.error.set(res.messages?.[0] || 'Failed to load roles');
          }
        },
        error: () => {
          this.error.set('Failed to load roles');
        }
      });
  }

  hasRole(roleName: string): boolean {
    return this.selectedRoles().includes(roleName);
  }

  toggleRole(roleName: string) {
    const current = this.selectedRoles();
    if (current.includes(roleName)) {
      this.selectedRoles.set(current.filter(r => r !== roleName));
    } else {
      this.selectedRoles.set([...current, roleName]);
    }
  }

  save() {
    this.saving.set(true);
    this.error.set(null);
    const cmd = new AssignUserRolesCommand({
      userId: this.data.user.id!,
      roles: this.selectedRoles()
    });
    
    this.adminClient.assignUserRoles(this.data.user.id!, cmd)
      .pipe(finalize(() => this.saving.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error && res.data?.succeeded !== false) {
            this.dialogRef.close(this.selectedRoles());
          } else {
            this.error.set(res.data?.errors?.[0] || res.messages?.[0] || 'Failed to assign roles');
          }
        },
        error: (err) => {
          this.error.set(err.message || 'An error occurred');
        }
      });
  }
}
