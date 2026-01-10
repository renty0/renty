import { Component, inject, OnInit, ViewChild, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { ImageUploaderComponent } from '../../../shared/components/image-uploader/image-uploader.component';
import { ToastService } from '../../../shared/services/toast.service';
import { CategoriesClient, CreateCategoryCommand, UpdateCategoryCommand, MediaFilesClient } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent } from '../../../shared/components/input/input';

@Component({
    selector: 'app-category-editor',
    standalone: true,
    imports: [
        CommonModule,
        ReactiveFormsModule,
        TranslateModule,
        MatIconModule,
        ImageUploaderComponent,
        LoadingButtonComponent,
        InputComponent
    ],
    templateUrl: './category-editor.component.html',
    styleUrl: './category-editor.component.scss'
})
export class CategoryEditorComponent implements OnInit {
    private fb = inject(FormBuilder);
    private apiClient = inject(CategoriesClient);
    private toast = inject(ToastService);
    public translate = inject(TranslateService);

    @Input() id: number | null = null;
    @Output() saved = new EventEmitter<void>();
    @Output() cancelled = new EventEmitter<void>();

    @ViewChild('logoUploader') logoUploader!: ImageUploaderComponent;

    form: FormGroup;
    isEditMode = false;
    categoryId: number | null = null;
    isLoading = false;
    isSaving = false;

    constructor() {
        this.form = this.fb.group({
            categoryName: ['', [Validators.required, Validators.maxLength(100)]],
            description: ['', [Validators.maxLength(500)]],
            logoId: [null]
        });
    }

    ngOnInit() {
        if (this.id) {
            this.isEditMode = true;
            this.categoryId = this.id;
            this.loadCategory(this.categoryId);
        }
    }

    private loadCategory(id: number) {
        this.isLoading = true;
        this.apiClient.getCategoryById(id).pipe(
            tap(category => {
                if (category) {
                    this.form.patchValue({
                        categoryName: category.categoryName,
                        description: category.description,
                        logoId: category.logoId
                    });

                    if (this.logoUploader) {
                        this.logoUploader.imageUrl = category.logoUrl || null;
                        this.logoUploader.fileId = category.logoId?.toString() || null;
                    }
                }
            }),
            finalize(() => this.isLoading = false),
            catchError(() => {
                this.toast.showError('errors.failedToLoadCategory');
                this.cancelled.emit();
                return of(null);
            })
        )
            .subscribe();
    }

    async submit() {
        if (this.form.invalid) {
            this.form.markAllAsTouched();
            return;
        }

        this.isSaving = true;

        try {
            const uploadSuccess = await this.logoUploader?.uploadFileAsync() ?? true;
            if (!uploadSuccess) {
                this.toast.showError('errors.failedToUploadLogo');
                this.isSaving = false;
                return;
            }

            const logoId = this.logoUploader?.fileId;

            if (this.isEditMode && this.categoryId) {
                const command = new UpdateCategoryCommand();
                command.id = this.categoryId;
                command.categoryName = this.form.value.categoryName;
                command.description = this.form.value.description;
                command.logoId = logoId ? (logoId as any) : undefined;

                this.apiClient.updateCategory(this.categoryId, command)
                    .pipe(
                        tap(() => {
                            this.toast.showSuccess('categories.messages.updateSuccess');
                            this.saved.emit();
                        }),
                        catchError(() => {
                            this.toast.showError('errors.failedToUpdateCategory');
                            return of(null);
                        }),
                        finalize(() => this.isSaving = false)
                    )
                    .subscribe();

            } else {
                const command = new CreateCategoryCommand();
                command.categoryName = this.form.value.categoryName;
                command.description = this.form.value.description;
                command.logoId = logoId ? (logoId as any) : undefined;

                this.apiClient.createCategory(command)
                    .pipe(
                        tap(() => {
                            this.toast.showSuccess('categories.messages.createSuccess');
                            this.saved.emit();
                        }),
                        catchError(() => {
                            this.toast.showError('errors.failedToCreateCategory');
                            return of(null);
                        }),
                        finalize(() => this.isSaving = false)
                    )
                    .subscribe();
            }
        } catch (e) {
            this.isSaving = false;
            this.toast.showError('errors.unexpectedError');
        }
    }

    cancel() {
        this.cancelled.emit();
    }
}
