// import { Component, computed, inject, signal } from '@angular/core';
// import { CommonModule } from '@angular/common';
// import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
// import { Router } from '@angular/router';
// import { MessageService } from 'primeng/api';
// import { ToastModule } from 'primeng/toast';
// import { ImageModule } from 'primeng/image';
// import { AuthService } from '../../core/services/auth.service';
// import { AccountClient, UpdateUserCommand, UserDto } from '../../core/api/api-client';
// import { catchError, finalize } from 'rxjs/operators';
// import { of } from 'rxjs';
// import { InputComponent } from '../../shared/components/input/input';
// import { LoadingButtonComponent } from '../../shared/components/loading-button/loading-button.component';
// import { TranslateModule } from '@ngx-translate/core';
// import { ProfileImageDialogComponent } from './components/profile-image-dialog/profile-image-dialog.component';

// @Component({
//   selector: 'app-profile',
//   standalone: true,
//   imports: [
//     CommonModule,
//     ReactiveFormsModule,
//     ToastModule,
//     ImageModule,
//     InputComponent,
//     LoadingButtonComponent,
//     TranslateModule,
//     ProfileImageDialogComponent,
//   ],
//   templateUrl: './profile.component.html',
//   styleUrl: './profile.component.scss',
//   providers: [MessageService],
// })
// export class ProfileComponent {
//   private fb = inject(FormBuilder);
//   private authService = inject(AuthService);
//   private accountClient = inject(AccountClient);
//   private messageService = inject(MessageService);
//   private router = inject(Router);

//   currentUser = signal<UserDto | null>(null);
//   isLoading = signal(false);
//   imageDialogVisible = signal(false);
//   isUploading = signal(false);

//   profileForm = this.fb.group({
//     firstName: ['', Validators.required],
//     lastName: ['', Validators.required],
//     email: [{ value: '', disabled: true }],
//     profilePictureUrl: [''],
//     address: [''],
//     city: [''],
//     country: [''],
//     bio: [''],
//   });

//   profileImageUrl = computed(() => {
//     return this.profileForm.get('profilePictureUrl')?.value || 'assets/default-avatar.png';
//   });

//   constructor() {
//     this.loadUserData();
//   }

//   loadUserData() {
//     const user = this.authService.getUserData();
//     if (user) {
//       this.currentUser.set(user);
//       this.profileForm.patchValue({
//         firstName: user.firstName,
//         lastName: user.lastName,
//         email: user.email,
//         profilePictureUrl: user.profilePictureUrl,
//         address: user.address,
//         city: user.city,
//         country: user.country,
//         bio: user.bio,
//       });
//     }
//   }

//   openImageDialog() {
//     this.imageDialogVisible.set(true);
//   }

//   onImageSaved(newUrl: string | null) {
//     if (newUrl) {
//       this.profileForm.patchValue({ profilePictureUrl: newUrl });
//       // We can optionally save immediately or wait for the user to click Save on the form.
//       // But since the image is already uploaded, better to just update the form view.
//       this.messageService.add({ severity: 'success', summary: 'Success', detail: 'Image updated' });
//     }
//   }

//   onSubmit() {
//     if (this.profileForm.invalid) return;

//     this.isLoading.set(true);
//     const formValue = this.profileForm.getRawValue();

//     const command = new UpdateUserCommand({
//       firstName: formValue.firstName || '',
//       lastName: formValue.lastName || '',
//       address: formValue.address || undefined,
//       city: formValue.city || undefined,
//       country: formValue.country || undefined,
//       bio: formValue.bio || undefined,
//       profilePictureUrl: formValue.profilePictureUrl || undefined,
//     });

//     this.accountClient
//       .updateProfile(command)
//       .pipe(
//         finalize(() => this.isLoading.set(false)),
//         catchError((err) => {
//           this.messageService.add({
//             severity: 'error',
//             summary: 'Error',
//             detail: 'Profile update failed',
//           });
//           return of(null);
//         }),
//       )
//       .subscribe((res) => {
//         if (res && res.success && res.user) {
//           this.authService.storeUserData(res.user);
//           this.currentUser.set(res.user);
//           this.messageService.add({
//             severity: 'success',
//             summary: 'Success',
//             detail: 'Profile updated',
//           });
//         }
//       });
//   }
// }
