import { Component, inject, Input, Output, EventEmitter, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { TranslateModule } from '@ngx-translate/core';
import { MediaClient } from '../../../core/api/api-client';
import { ToastService } from '../../services/toast.service';
import { firstValueFrom } from 'rxjs';

export interface UploadedImage {
    id: number | null; // null for new uploads not yet saved to ProductImage (but saved to MediaFile)
    mediaFileId?: string; // ID from MediaFile service
    imageUrl: string;
    isPrimary: boolean;
    displayOrder: number;
    file?: File; // For local preview before upload
    isUploading?: boolean;
}

@Component({
    selector: 'app-multi-image-uploader',
    standalone: true,
    imports: [CommonModule, MatIconModule, MatProgressBarModule, TranslateModule],
    templateUrl: './multi-image-uploader.component.html',
    styleUrl: './multi-image-uploader.component.scss'
})
export class MultiImageUploaderComponent {
    private apiClient = inject(MediaClient);
    private toast = inject(ToastService);
    private cdr = inject(ChangeDetectorRef);

    @Input() images: UploadedImage[] = [];
    @Output() imagesChange = new EventEmitter<UploadedImage[]>();

    isUploading = false;

    triggerFileInput(fileInput: HTMLInputElement) {
        fileInput.click();
    }

    async onFilesSelected(event: Event) {
        const input = event.target as HTMLInputElement;
        if (!input.files?.length) return;

        const files = Array.from(input.files);

        // Validate files
        const validFiles = files.filter(file => {
            if (!file.type.startsWith('image/')) {
                this.toast.showError(`Invalid file type: ${file.name}`);
                return false;
            }
            if (file.size > 5 * 1024 * 1024) {
                this.toast.showError(`File too large: ${file.name}`);
                return false;
            }
            return true;
        });

        if (validFiles.length === 0) return;

        this.isUploading = true;

        for (const file of validFiles) {
            await this.uploadFile(file);
        }

        this.isUploading = false;
        input.value = ''; // Reset input
        this.cdr.markForCheck();
    }

    async uploadFile(file: File) {
        const tempImage: UploadedImage = {
            id: -1, // Temporary negative ID
            imageUrl: URL.createObjectURL(file), // Preview
            isPrimary: this.images.length === 0,
            displayOrder: this.images.length,
            isUploading: true
        };

        this.images.push(tempImage);
        this.cdr.markForCheck();

        try {
            const fileParam = {
                data: file,
                fileName: file.name
            };

            const response: any = await firstValueFrom(
                this.apiClient.uploadMedia(undefined, undefined, fileParam)
            );

            if (response.id) {
                // Update temp image with real data
                tempImage.mediaFileId = response.id;
                tempImage.imageUrl = response.urls?.medium || response.url || '';
                tempImage.isUploading = false;
                // Only new images need to be communicated as "URLs" to the CreateProduct,
                // but for UpdateProduct we need ProductImageDto structure.
                // The parent component will handle the mapping.
                this.emitChanges();
            } else {
                this.removeImage(tempImage);
                this.toast.showError(`Failed to upload ${file.name}`);
            }
        } catch (error) {
            this.removeImage(tempImage);
            this.toast.showError(`Failed to upload ${file.name}`);
            console.error(error);
        }
    }

    removeImage(image: UploadedImage) {
        const index = this.images.indexOf(image);
        if (index > -1) {
            this.images.splice(index, 1);

            // If primary was removed, make the first one primary
            if (image.isPrimary && this.images.length > 0) {
                this.images[0].isPrimary = true;
            }

            // Reorder
            this.reorderImages();
            this.emitChanges();
        }
    }

    setPrimary(image: UploadedImage) {
        this.images.forEach(img => img.isPrimary = false);
        image.isPrimary = true;
        this.emitChanges();
    }

    reorderImages() {
        this.images.forEach((img, index) => img.displayOrder = index);
    }

    emitChanges() {
        this.imagesChange.emit(this.images);
    }
}
