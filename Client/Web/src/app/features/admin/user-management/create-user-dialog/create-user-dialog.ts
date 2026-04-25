import { Component, inject, signal } from '@angular/core';
import { finalize } from 'rxjs';
import { AdminClient, CreateAdminUserCommand } from '../../../../core/api/api-client';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { ToastService } from '../../../../shared/services/toast.service';
import { TranslateModule } from '@ngx-translate/core';
import { InputComponent } from '../../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';

@Component({
  selector: 'app-create-user-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatDialogModule,
    MatButtonModule,
    MatSelectModule,
    MatIconModule,
    ReactiveFormsModule,
    TranslateModule,
    InputComponent,
    LoadingButtonComponent
  ],
  templateUrl: './create-user-dialog.html',
  styleUrl: './create-user-dialog.scss'
})
export class CreateUserDialogComponent {
  private fb = inject(FormBuilder);
  private adminClient = inject(AdminClient);
  private toast = inject(ToastService);
  private dialogRef = inject(MatDialogRef<CreateUserDialogComponent>);

  isSaving = signal(false);

  roleOptions = [
    { name: 'Admin', code: 'Admin' },
    { name: 'Support', code: 'Support' },
    { name: 'Expert', code: 'Expert' },
  ];

  userForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    roles: [<string[]>[], [Validators.required]]
  });

  save(): void {
    if (this.userForm.invalid) return;

    this.isSaving.set(true);
    const cmd = new CreateAdminUserCommand({
      email: this.userForm.value.email!,
      password: this.userForm.value.password!,
      firstName: this.userForm.value.firstName!,
      lastName: this.userForm.value.lastName!,
      roles: this.userForm.value.roles!
    });

    this.adminClient.createAdminUser(cmd)
      .pipe(finalize(() => this.isSaving.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error) {
            this.toast.showSuccess(res.messages?.[0] || 'User created successfully');
            this.dialogRef.close(true);
          } else {
            this.toast.showError(res.messages?.[0] || 'Failed to create user');
          }
        },
        error: (err) => {
          this.toast.showError('Failed to create user');
          console.error(err);
        }
      });
  }
}
