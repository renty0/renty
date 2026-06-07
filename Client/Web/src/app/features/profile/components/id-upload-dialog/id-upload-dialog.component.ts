import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatDialogRef, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule } from '@ngx-translate/core';
import { MediaClient, FileParameter } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';
import { firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-id-upload-dialog',
  standalone: true,
  imports: [
    CommonModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    TranslateModule
  ],
  templateUrl: './id-upload-dialog.component.html',
  styleUrl: './id-upload-dialog.component.scss'
})
export class IdUploadDialogComponent {
  private dialogRef = inject(MatDialogRef<IdUploadDialogComponent>);
  private mediaClient = inject(MediaClient);
  private toastService = inject(ToastService);

  frontImage: string | null = null;
  backImage: string | null = null;
  frontFile: File | null = null;
  backFile: File | null = null;
  isUploading = false;

  onFrontSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      this.frontFile = input.files[0];
      this.frontImage = URL.createObjectURL(this.frontFile);
    }
  }

  onBackSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      this.backFile = input.files[0];
      this.backImage = URL.createObjectURL(this.backFile);
    }
  }

  removeFront() {
    this.frontImage = null;
    this.frontFile = null;
  }

  removeBack() {
    this.backImage = null;
    this.backFile = null;
  }

  async upload() {
    if (!this.frontFile || !this.backFile) {
      this.toastService.showError('profile.uploadBothSides');
      return;
    }

    this.isUploading = true;

    try {
      const frontParam: FileParameter = { data: this.frontFile, fileName: this.frontFile.name };
      const frontRes = await firstValueFrom(this.mediaClient.uploadMedia(undefined, undefined, frontParam));
      const frontUrl = frontRes?.data?.url;
      const backParam: FileParameter = { data: this.backFile, fileName: this.backFile.name };
      const backRes = await firstValueFrom(this.mediaClient.uploadMedia(undefined, undefined, backParam));
      const backUrl = backRes?.data?.url;

      if (frontUrl && backUrl) {
        this.dialogRef.close({ frontUrl, backUrl });
      } else {
        this.toastService.showError('error.uploadFailed');
      }
    } catch (err) {
      this.toastService.showError('error.uploadFailed');
    } finally {
      this.isUploading = false;
    }
  }

  cancel() {
    this.dialogRef.close();
  }
}
