import { Component, EventEmitter, Input, Output, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DialogModule } from 'primeng/dialog';
import { ButtonModule } from 'primeng/button';
import { ImageUploaderComponent } from '../../../../shared/components/image-uploader/image-uploader.component';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { TranslateModule } from '@ngx-translate/core';

@Component({
    selector: 'app-profile-image-dialog',
    standalone: true,
    imports: [
        CommonModule,
        DialogModule,
        ButtonModule,
        ImageUploaderComponent,
        ReactiveFormsModule,
        TranslateModule
    ],
    templateUrl: './profile-image-dialog.component.html',
    styleUrls: ['./profile-image-dialog.component.scss']
})
export class ProfileImageDialogComponent {
    @Input() visible = false;
    @Input() currentImageUrl: string | null = null;
    @Output() visibleChange = new EventEmitter<boolean>();
    @Output() imageSaved = new EventEmitter<string | null>();

    @ViewChild(ImageUploaderComponent) uploader!: ImageUploaderComponent;

    form = new FormGroup({
        imageId: new FormControl('')
    });

    close() {
        this.visible = false;
        this.visibleChange.emit(false);
    }

    save() {
        const newImageId = this.form.get('imageId')?.value;
        if (newImageId) {
            const newUrl = this.uploader.imageUrl;
            this.imageSaved.emit(newUrl);
        } else {
            this.imageSaved.emit(this.uploader.imageUrl);
        }
        this.close();
    }
}
