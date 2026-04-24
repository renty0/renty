import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ToastService } from '../../../../shared/services/toast.service';
import { environment } from '../../../../../environments/environment';
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
  private http = inject(HttpClient);
  private toast = inject(ToastService);
  private dialogRef = inject(MatDialogRef<CreateUserDialogComponent>);
  private baseUrl = environment.apiUrl;

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
    this.http.post(`${this.baseUrl}/api/v1/admin/users`, this.userForm.value).subscribe({
      next: () => {
        this.toast.showSuccess('User created successfully');
        this.dialogRef.close(true);
      },
      error: (err: any) => {
        const errorMsg = err.error?.message || 'Failed to create user';
        this.toast.showError(errorMsg);
        this.isSaving.set(false);
      }
    });
  }
}
