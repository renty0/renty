import { Component, inject, OnInit, ViewChild, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { ImageUploaderComponent } from '../../../shared/components/image-uploader/image-uploader.component';
import { ToastService } from '../../../shared/services/toast.service';
import { CategoriesClient, CreateCategoryCommand, UpdateCategoryCommand } from '../../../core/api/api-client';
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
    @Output() saved = new EventEmitter<{
        id: number;
        categoryNameAr?: string;
        categoryNameEn?: string;
        descriptionAr?: string;
        descriptionEn?: string;
        logoUrl?: string;
        logoId?: number
    }>();
    @Output() cancelled = new EventEmitter<void>();

    @ViewChild('logoUploader') logoUploader!: ImageUploaderComponent;

    form: FormGroup;
    isEditMode = false;
    categoryId: number | null = null;
    isLoading = false;
    isSaving = false;

    constructor() {
        this.form = this.fb.group({
            categoryNameAr: ['', [Validators.required, Validators.maxLength(100)]],
            categoryNameEn: ['', [Validators.required, Validators.maxLength(100)]],
            descriptionAr: ['', [Validators.maxLength(500)]],
            descriptionEn: ['', [Validators.maxLength(500)]],
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
                        categoryNameAr: category?.data?.nameAr,
                        categoryNameEn: category?.data?.nameEn,
                        descriptionAr: category?.data?.descAr,
                        descriptionEn: category?.data?.descEn,
                        logoId: category?.data?.logoId
                    });

                    if (this.logoUploader) {
                        this.logoUploader.imageUrl = category?.data?.logoUrl || null;
                        this.logoUploader.fileId = category?.data?.logoId?.toString() || null;
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
                command.nameAr = this.form.value.categoryNameAr;
                command.nameEn = this.form.value.categoryNameEn;
                command.descAr = this.form.value.descriptionAr;
                command.descEn = this.form.value.descriptionEn;
                command.logoId = logoId ? (logoId as any) : undefined;

                this.apiClient.updateCategory(this.categoryId, command)
                    .pipe(
                        tap((res) => {
                            this.toast.showSuccess(res.message ? res.message : 'categories.messages.updateSuccess');
                            // Emit the updated category data
                            if (res.data) {
                                this.saved.emit({
                                    id: res?.data?.id!,
                                    categoryNameAr: res?.data?.nameAr!,
                                    categoryNameEn: res?.data?.nameEn!,
                                    descriptionAr: res?.data?.descAr,
                                    descriptionEn: res?.data?.descEn,
                                    logoUrl: res?.data?.logoUrl,
                                    logoId: res?.data?.logoId ? Number(res?.data?.logoId) : undefined
                                });
                            }
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
                command.nameAr = this.form.value.categoryNameAr;
                command.nameEn = this.form.value.categoryNameEn;
                command.descAr = this.form.value.descriptionAr;
                command.descEn = this.form.value.descriptionEn;
                command.logoId = logoId ? (logoId as any) : undefined;

                this.apiClient.createCategory(command)
                    .pipe(
                        tap((res) => {
                            this.toast.showSuccess(res.message ? res.message : 'categories.messages.createSuccess');
                            if (res.data) {
                                this.saved.emit({
                                    id: res.data.id!,
                                    categoryNameAr: res.data.nameAr!,
                                    categoryNameEn: res.data.nameEn!,
                                    descriptionAr: res.data.descAr,
                                    descriptionEn: res.data.descEn,
                                    logoUrl: res.data.logoUrl,
                                    logoId: res.data.logoId ? Number(res.data.logoId) : undefined
                                });
                            }
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
