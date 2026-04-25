import { Component, computed, inject, signal, DestroyRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from '../../shared/services/toast.service';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { AuthService } from '../../core/services/auth.service';
import { AuthClient, AuthLoginUser, UpdateUserCommand } from '../../core/api/api-client';
import { InputComponent } from '../../shared/components/input/input';
import { TranslateModule } from '@ngx-translate/core';
import { ProfileImageDialogComponent } from './components/profile-image-dialog/profile-image-dialog.component';

import { LoadingButtonComponent } from '../../shared/components/loading-button/loading-button.component';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatIconModule,
    MatButtonModule,
    MatDialogModule,
    MatProgressSpinnerModule,
    InputComponent,
    TranslateModule,
    LoadingButtonComponent
  ],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
})
export class ProfileComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private authClient = inject(AuthClient);
  private toastService = inject(ToastService);
  private router = inject(Router);
  private dialog = inject(MatDialog);
  private destroyRef = inject(DestroyRef);

  currentUser = signal<any | null>(null);
  isLoading = signal(false);
  isUploading = signal(false);
  
  editingField = signal<string | null>(null);
  savingField = signal<string | null>(null);

  profileForm = this.fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    email: [{ value: '', disabled: true }],
    profilePictureUrl: [''],
    address: [''],
    city: [''],
    country: [''],
    bio: [''],
  });

  profileImageUrl = computed(() => {
    return this.profileForm.get('profilePictureUrl')?.value || 'assets/profile.webp';
  });

  constructor() {
    this.loadUserData();
  }

  loadUserData() {
    const user = this.authService.getUserData() as any;
    if (user) {
      this.currentUser.set(user);
      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        profilePictureUrl: user.profilePictureUrl,
        address: user.address,
        city: user.city,
        country: user.country,
        bio: user.bio,
      });
    }
  }

  openImageDialog() {
    const dialogRef = this.dialog.open(ProfileImageDialogComponent, {
      width: '650px',
      maxWidth: '90vw',
      disableClose: false,
      data: { currentImageUrl: this.profileImageUrl() }
    });

    dialogRef.afterClosed().subscribe(newUrl => {
      this.onImageSaved(newUrl);
    });
  }

  onImageSaved(newUrl: string | null | undefined) {
    if (newUrl) {
      this.profileForm.patchValue({ profilePictureUrl: newUrl });
      this.saveField('profilePictureUrl');
    }
  }

  startEdit(field: string) {
    this.editingField.set(field);
  }

  cancelEdit(field: string) {
    const user = this.currentUser();
    if (user) {
      this.profileForm.get(field)?.setValue((user as any)[field] || '');
    }
    this.editingField.set(null);
  }

  onSubmit() {
    if (this.profileForm.invalid) return;
    
    this.isLoading.set(true);
    const formVals = this.profileForm.getRawValue();
    const command = new UpdateUserCommand({
      firstName: formVals.firstName || undefined,
      lastName: formVals.lastName || undefined,
      phoneNumber: undefined,
      address: formVals.address || undefined,
      city: formVals.city || undefined,
      country: formVals.country || undefined,
      bio: formVals.bio || undefined,
      profilePictureUrl: formVals.profilePictureUrl || undefined
    });

    this.authClient.authUpdateMe(command)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.toastService.showSuccess('profile.updated');
          this.isLoading.set(false);
          this.profileForm.markAsPristine();
          
          const currentUserObj = this.currentUser();
          const updatedUser = { ...currentUserObj, ...command };
          this.currentUser.set(updatedUser as AuthLoginUser);
          this.authService.storeUserData(updatedUser as AuthLoginUser);
        },
        error: (err) => {
          this.toastService.showError('error.updateFailed');
          this.isLoading.set(false);
        }
      });
  }

  saveField(field: string) {
    const control = this.profileForm.get(field);
    if (control?.invalid) return;

    this.savingField.set(field);
    
    const formVals = this.profileForm.getRawValue();
    const command = new UpdateUserCommand({
      firstName: formVals.firstName || undefined,
      lastName: formVals.lastName || undefined,
      phoneNumber: undefined, // Currently no field, but allowed by API
      address: formVals.address || undefined,
      city: formVals.city || undefined,
      country: formVals.country || undefined,
      bio: formVals.bio || undefined,
      profilePictureUrl: formVals.profilePictureUrl || undefined
    });

    this.authClient.authUpdateMe(command)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: () => {
          this.toastService.showSuccess('profile.updated');
          this.savingField.set(null);
          this.editingField.set(null);
          
          // Update currentUser signal and localStorage
          const currentUserObj = this.currentUser();
          const updatedUser = { ...currentUserObj, ...command };
          this.currentUser.set(updatedUser as AuthLoginUser);
          this.authService.storeUserData(updatedUser as AuthLoginUser);
        },
        error: (err) => {
          this.toastService.showError('error.updateFailed');
          this.savingField.set(null);
        }
      });
  }
}

