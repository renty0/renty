import { Component, inject, Input, ViewChild, ElementRef, ChangeDetectorRef, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { firstValueFrom } from 'rxjs';
import { ToastService } from '../../services/toast.service';
import { MediaClient } from '../../../core/api/api-client';

import { MatIconModule } from '@angular/material/icon';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-image-uploader',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, MatProgressBarModule, MatIconModule, TranslateModule],
  templateUrl: './image-uploader.component.html',
  styleUrl: './image-uploader.component.scss'
})
export class ImageUploaderComponent implements OnInit, OnChanges {
  private toast = inject(ToastService);
  private cdr = inject(ChangeDetectorRef);
  private apiClient = inject(MediaClient);

  @ViewChild('fileInput', { static: false })
  fileInputRef!: ElementRef<HTMLInputElement>;

  @Input() formGroup!: FormGroup;
  @Input() controlName!: string;
  @Input() label!: string;
  @Input() imgUrl: string | null = null;
  @Input() uploadPath: string = '';
  @Input() folder: string = '';
  @Input() allowedExtensions: string[] = [];
  @Input() allowedTypes: string[] = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
  @Input() maxSize = 5 * 1024 * 1024; // 5MB

  fileId: string | null = null;
  selectedFile: File | null = null;
  imageUrl: string | null = null;
  imageName: string | null = null;
  previewUrl: string | null = null;
  isDragging = false;
  isUploading = false;
  uploadProgress = 0;
  ngOnInit() {
    if (this.imgUrl) {
      this.imageUrl = this.imgUrl;
      this.imageName = this.extractFileName(this.imgUrl);
      this.cdr.markForCheck();
    }
  }
  ngOnChanges(changes: SimpleChanges) {
    if (changes['imgUrl'] && changes['imgUrl'].currentValue !== changes['imgUrl'].previousValue) this.resetToInitialState();
  }
  get formControl(): FormControl | null {
    if (!this.formGroup || !this.controlName) return null;
    return this.formGroup.get(this.controlName) as FormControl;
  }
  get hasError(): boolean {
    const control = this.formControl;
    return (control?.invalid && control?.touched) || false;
  }
  get hasPendingFile(): boolean {
    return this.selectedFile !== null;
  }
  triggerFileInput(): void {
    if (!this.isUploading) this.fileInputRef.nativeElement.click();
  }
  onFileSelected(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (file) this.handleFile(file);
  }
  onDrop(event: DragEvent): void {
    event.preventDefault();
    this.isDragging = false;
    const file = event.dataTransfer?.files?.[0];
    if (file) this.handleFile(file);
    this.cdr.markForCheck();
  }
  onDragOver(event: DragEvent): void {
    event.preventDefault();
    if (!this.isDragging) {
      this.isDragging = true;
      this.cdr.markForCheck();
    }
  }
  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    if (!event.currentTarget || !(event.currentTarget as Element).contains(event.relatedTarget as Node)) {
      this.isDragging = false;
      this.cdr.markForCheck();
    }
  }
  private handleFile(file: File): void {
    if (!this.validateFile(file)) return;
    this.selectedFile = file;
    this.imageName = file.name;
    this.imageUrl = null;
    this.uploadProgress = 0;
    this.createPreview(file);
    this.cdr.markForCheck();
    this.autoUpload();
  }

  private autoUpload(): void {
    if (!this.selectedFile) return;
    this.isUploading = true;
    this.uploadProgress = 0;
    const progressInterval = setInterval(() => {
      if (this.uploadProgress < 90) {
        this.uploadProgress += Math.random() * 5;
        this.cdr.markForCheck();
      }
    }, 50);

    const fileParam = {
      data: this.selectedFile,
      fileName: this.selectedFile.name
    };

    this.apiClient.uploadMedia(undefined, undefined, fileParam).subscribe({
      next: (response: any) => {
        clearInterval(progressInterval);
        this.uploadProgress = 100;

        const data = response?.data || response; // Support both unwrapped and wrapped

        if (data && data.id) {
          this.formControl?.setValue(data.id);
          this.fileId = data.id;
          this.imageUrl = data.urls?.medium || data.url || '';
          this.imageName = data.originalFileName || data.fileName || this.selectedFile!.name;
          this.selectedFile = null;
          this.previewUrl = null;
        } else {
          this.handleUploadError('Upload failed');
        }
        this.isUploading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        clearInterval(progressInterval);
        this.handleUploadError('Upload failed. Please try again.');
      }
    });
  }
  private createPreview(file: File): void {
    const reader = new FileReader();
    reader.onload = (e) => {
      this.previewUrl = e.target?.result as string;
      this.cdr.markForCheck();
    };
    reader.readAsDataURL(file);
  }
  private validateFile(file: File): boolean {
    if (!this.allowedTypes.includes(file.type)) {
      this.toast.showError('uploader.invalidImageType');
      return false;
    }
    if (file.size > this.maxSize) {
      this.toast.showError('uploader.fileTooLarge');
      return false;
    }
    return true;
  }
  uploadFile(event: Event): void {
    event.stopPropagation();
    if (!this.selectedFile) {
      this.toast.showError('uploader.selectFileFirst');
      return;
    }
    this.isUploading = true;
    this.uploadProgress = 0;
    const progressInterval = setInterval(() => {
      if (this.uploadProgress < 90) {
        this.uploadProgress += Math.random() * 5;
        this.cdr.markForCheck();
      }
    }, 50);

    const fileParam = {
      data: this.selectedFile,
      fileName: this.selectedFile.name
    };

    this.apiClient.uploadMedia(undefined, undefined, fileParam).subscribe({
      next: (response: any) => {
        clearInterval(progressInterval);
        this.uploadProgress = 100;

        const data = response?.data || response;

        if (data && data.id) {
          this.formControl?.setValue(data.id);
          this.fileId = data.id;
          this.imageUrl = data.urls?.medium || data.url || '';
          this.imageName = data.originalFileName || data.fileName || this.selectedFile!.name;
          this.selectedFile = null;
          this.previewUrl = null;
          this.toast.showSuccess('uploader.uploadSuccess');
        } else {
          this.handleUploadError('uploader.uploadFailed');
        }
        this.isUploading = false;
        this.cdr.markForCheck();
      },
      error: () => {
        clearInterval(progressInterval);
        this.handleUploadError('uploader.uploadFailedRetry');
      }
    });
  }
  resetState(event: Event): void {
    event.stopPropagation();
    this.selectedFile = null;
    this.imageUrl = null;
    this.imageName = null;
    this.previewUrl = null;
    this.uploadProgress = 0;
    this.isUploading = false;
    this.formControl?.setValue(null);
    this.cdr.markForCheck();
  }
  private handleUploadError(message: string): void {
    this.isUploading = false;
    this.uploadProgress = 0;
    this.toast.showError(message);
    this.cdr.markForCheck();
  }
  private extractFileName(url: string): string {
    try {
      return url.split('/').pop() || 'Current image';
    } catch {
      return 'Current image';
    }
  }
  getFileSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }
  private resetToInitialState(): void {
    this.selectedFile = null;
    this.previewUrl = null;
    this.uploadProgress = 0;
    this.isUploading = false;
    if (this.imgUrl) {
      this.imageUrl = this.imgUrl;
      this.imageName = this.extractFileName(this.imgUrl);
    } else {
      this.imageUrl = null;
      this.imageName = null;
      this.formControl?.setValue(null);
    }
    this.cdr.markForCheck();
  }

  async uploadFileAsync(): Promise<boolean> {
    if (!this.selectedFile) return true;
    this.isUploading = true;
    this.uploadProgress = 0;
    const progressInterval = setInterval(() => {
      if (this.uploadProgress < 90) {
        this.uploadProgress += Math.random() * 5;
        this.cdr.markForCheck();
      }
    }, 50);

    try {
      const fileParam = {
        data: this.selectedFile,
        fileName: this.selectedFile.name
      };

      const response: any = await firstValueFrom(
        this.apiClient.uploadMedia(undefined, undefined, fileParam)
      );

      clearInterval(progressInterval);
      this.uploadProgress = 100;

      const data = response?.data || response;

      if (data && data.id) {
        this.formControl?.setValue(data.id);
        this.fileId = data.id;
        this.imageUrl = data.urls?.medium || data.url || '';
        this.imageName = data.originalFileName || data.fileName || this.selectedFile.name;
        this.selectedFile = null;
        this.previewUrl = null;
        this.toast.showSuccess('uploader.uploadSuccess');
        this.isUploading = false;
        this.cdr.markForCheck();
        return true;
      } else {
        this.handleUploadError('uploader.uploadFailed');
        return false;
      }
    } catch (error) {
      clearInterval(progressInterval);
      this.handleUploadError('uploader.uploadFailedRetry');
      return false;
    }
  }
}
