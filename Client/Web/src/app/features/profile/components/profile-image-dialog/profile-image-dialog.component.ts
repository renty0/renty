import { Component, Inject, ViewChild } from '@angular/core';

import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

import { ImageUploaderComponent } from '../../../../shared/components/image-uploader/image-uploader.component';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { TranslateModule } from '@ngx-translate/core';

@Component({
    selector: 'app-profile-image-dialog',
    standalone: true,
    imports: [
    ImageUploaderComponent,
    ReactiveFormsModule,
    TranslateModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule
],
    templateUrl: './profile-image-dialog.component.html',
    styleUrl: './profile-image-dialog.component.scss'
})
export class ProfileImageDialogComponent {
    @ViewChild(ImageUploaderComponent) uploader!: ImageUploaderComponent;

    form = new FormGroup({
        imageId: new FormControl('')
    });

    constructor(
        public dialogRef: MatDialogRef<ProfileImageDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public data: { currentImageUrl: string | null }
    ) {}

    close() {
        this.dialogRef.close();
    }

    save() {
        const newImageId = this.form.get('imageId')?.value;
        if (newImageId) {
            const newUrl = this.uploader.imageUrl;
            this.dialogRef.close(newUrl);
        } else {
            this.dialogRef.close(this.uploader.imageUrl);
        }
    }
}

