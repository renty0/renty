import { Component, Inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
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
    MatProgressSpinnerModule
  ],
  template: `
    <h2 mat-dialog-title>Assign Roles to {{ data.user.firstName }}</h2>
    <mat-dialog-content>
      <div class="flex flex-col gap-4 py-4 min-w-[300px]">
        <div *ngIf="loading()" class="flex justify-center p-4">
          <mat-spinner diameter="32"></mat-spinner>
        </div>
        
        <div *ngIf="!loading()" class="flex flex-col gap-3">
          <p class="text-surface-500 mb-2">Select roles for this user:</p>
          <div *ngFor="let role of availableRoles()" class="flex items-center">
            <mat-checkbox 
              [checked]="hasRole(role.name!)"
              (change)="toggleRole(role.name!)">
              {{ role.name }}
            </mat-checkbox>
          </div>
          <div *ngIf="availableRoles().length === 0" class="text-surface-500 italic">
            No roles available to assign.
          </div>
        </div>
        <div *ngIf="error()" class="text-red-500 text-sm mt-2">
          {{ error() }}
        </div>
      </div>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancel</button>
      <button mat-raised-button color="primary" [disabled]="loading() || saving()" (click)="save()">Save</button>
    </mat-dialog-actions>
  `
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
    this.adminClient.getAdminRoles().subscribe({
      next: (res) => {
        this.availableRoles.set(res.data || []);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Failed to load roles');
        this.loading.set(false);
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
    
    this.adminClient.assignUserRoles(this.data.user.id!, cmd).subscribe({
      next: (res) => {
        if (res.data?.succeeded) {
          this.dialogRef.close(this.selectedRoles());
        } else {
          this.error.set(res.data?.errors?.[0] || 'Failed to assign roles');
          this.saving.set(false);
        }
      },
      error: (err) => {
        this.error.set(err.message || 'An error occurred');
        this.saving.set(false);
      }
    });
  }
}
