import { Component, computed, inject, signal, DestroyRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from '../../shared/services/toast.service';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTabsModule } from '@angular/material/tabs';
import { AuthService } from '../../core/services/auth.service';
import { AuthClient, AuthLoginUser, UpdateUserCommand, DeleteUserResponse } from '../../core/api/api-client';
import { InputComponent, SelectOption } from '../../shared/components/input/input';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { EGYPT_GOVERNORATES } from '../items/items-editor-page/items-editor.constants';
import { ProfileImageDialogComponent } from './components/profile-image-dialog/profile-image-dialog.component';
import { ConfirmDialogComponent } from '../../shared/components/confirm-dialog/confirm-dialog.component';

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
    MatTabsModule,
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
  private translate = inject(TranslateService);

  currentUser = signal<any | null>(null);
  isLoading = signal(false);
  isUploading = signal(false);

  editingField = signal<string | null>(null);
  savingField = signal<string | null>(null);

  countryOptions: SelectOption[] = [
    { name: 'countries.egypt', code: 'egypt' }
  ];

  egyptianCities: SelectOption[] = EGYPT_GOVERNORATES;

  // MOCK DATA until backend exposes per-role ratings and reviews
  mockReviews = signal<any[]>([
    {
      id: '1',
      reviewerName: 'Ahmed Ali',
      reviewerImage: 'assets/profile.webp',
      rating: 5,
      comment: 'Great person to deal with. The item was exactly as described and in perfect condition.',
      createdAt: new Date(Date.now() - 86400000 * 2),
      role: 'owner'
    },
    {
      id: '2',
      reviewerName: 'Sara Kamel',
      reviewerImage: '',
      rating: 4,
      comment: 'Very smooth transaction. Was a bit late for pickup but overall great.',
      createdAt: new Date(Date.now() - 86400000 * 10),
      role: 'renter'
    }
  ]);

  ownerRating = computed(() => {
    const u = this.currentUser();
    return u?.ownerRating || 4.8;
  });

  renterRating = computed(() => {
    const u = this.currentUser();
    return u?.renterRating || 4.5;
  });

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
        city: user.city?.toLowerCase() || 'cairo',
        country: user.country?.toLowerCase() || 'egypt',
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
    deleteAccount() {
      const dialogRef = this.dialog.open(ConfirmDialogComponent, {
        width: '400px',
        data: {
          title: this.translate.instant('profile.deleteConfirmTitle'),
          message: this.translate.instant('profile.deleteConfirmMessage'),
          confirmText: this.translate.instant('common.delete'),
          cancelText: this.translate.instant('common.cancel'),
          color: 'warn'
        }
      });

      dialogRef.afterClosed().subscribe(result => {
        if (result) {
          this.isLoading.set(true);
          this.authClient.authDeleteMe()
            .pipe(takeUntilDestroyed(this.destroyRef))
            .subscribe({
              next: () => {
                this.toastService.showSuccess('profile.deleteSuccess');
                this.authService.logout();
                this.router.navigate(['/auth/login']);
                this.isLoading.set(false);
              },
              error: () => {
                this.toastService.showError('error.updateFailed');
                this.isLoading.set(false);
              }
            });
        }
      });
    }
  }

