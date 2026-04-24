import { Component, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastService } from '../../shared/services/toast.service';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { AuthService } from '../../core/services/auth.service';
import { AuthLoginUser } from '../../core/api/api-client';
import { InputComponent } from '../../shared/components/input/input';
import { LoadingButtonComponent } from '../../shared/components/loading-button/loading-button.component';
import { TranslateModule } from '@ngx-translate/core';
import { ProfileImageDialogComponent } from './components/profile-image-dialog/profile-image-dialog.component';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatIconModule,
    MatDialogModule,
    InputComponent,
    LoadingButtonComponent,
    TranslateModule,
  ],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
})
export class ProfileComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private toastService = inject(ToastService);
  private router = inject(Router);
  private dialog = inject(MatDialog);

  currentUser = signal<AuthLoginUser | null>(null);
  isLoading = signal(false);
  isUploading = signal(false);

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
    return this.profileForm.get('profilePictureUrl')?.value || 'assets/default-avatar.png';
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
      this.toastService.showSuccess('Image updated');
    }
  }

  onSubmit() {
    if (this.profileForm.invalid) return;

    this.isLoading.set(true);

    // Mock API call since Renty API currently lacks an account update endpoint
    setTimeout(() => {
      this.isLoading.set(false);
      this.toastService.showSuccess('Profile updated');
    }, 1000);
  }
}


