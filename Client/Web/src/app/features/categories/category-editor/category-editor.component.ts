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
  imports: [ CommonModule, ReactiveFormsModule, TranslateModule, MatIconModule, ImageUploaderComponent, LoadingButtonComponent, InputComponent ],
  templateUrl: './category-editor.component.html',
  styleUrl: './category-editor.component.scss',
})
export class CategoryEditorComponent implements OnInit {
  private fb = inject(FormBuilder);
  private apiClient = inject(CategoriesClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  @Input() id: number | null = null;
  @Output() saved = new EventEmitter<{
    id: number;
    nameEn: string;
    nameAr?: string;
    descriptionEn?: string;
    descriptionAr?: string;
    logoUrl?: string;
    logoId?: number;
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
      nameEn: ['', [Validators.required, Validators.maxLength(100)]],
      nameAr: ['', [Validators.maxLength(100)]],
      descriptionEn: ['', [Validators.maxLength(500)]],
      descriptionAr: ['', [Validators.maxLength(500)]],
      logoId: [null, Validators.required],
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
    this.apiClient
      .getCategoryById(id)
      .pipe(
        tap((category) => {
          if (category) {
            this.form.patchValue({
              nameEn: category.nameEn,
              nameAr: category.nameAr,
              descriptionEn: category.descriptionEn,
              descriptionAr: category.descriptionAr,
              logoId: category.logoId,
            });
            if (this.logoUploader) {
              this.logoUploader.imageUrl = category.logoUrl || null;
              this.logoUploader.fileId = category.logoId?.toString() || null;
            }
          }
        }),
        finalize(() => (this.isLoading = false)),
        catchError(() => {
          this.toast.showError('errors.failedToLoadCategory');
          this.cancelled.emit();
          return of(null);
        }),
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
      const uploadSuccess = (await this.logoUploader?.uploadFileAsync()) ?? true;
      if (!uploadSuccess) {
        this.toast.showError('errors.failedToUploadLogo');
        this.isSaving = false;
        return;
      }

      const logoId = this.logoUploader?.fileId;

      if (this.isEditMode && this.categoryId) {
        const command = new UpdateCategoryCommand();
        command.id = this.categoryId;
        command.nameEn = this.form.value.nameEn;
        command.nameAr = this.form.value.nameAr;
        command.descriptionEn = this.form.value.descriptionEn;
        command.descriptionAr = this.form.value.descriptionAr;
        command.logoId = logoId ? (logoId as any) : undefined;

        this.apiClient
          .updateCategory(this.categoryId, command)
          .pipe(
            tap((res) => {
              this.toast.showSuccess(
                res.message ? res.message : 'categories.messages.updateSuccess',
              );
              if (res.category) {
                this.saved.emit({
                  id: res.category.id!,
                  nameEn: res.category.nameEn!,
                  nameAr: res.category.nameAr,
                  descriptionEn: res.category.descriptionEn,
                  descriptionAr: res.category.descriptionAr,
                  logoUrl: res.category.logoUrl,
                  logoId: res.category.logoId ? Number(res.category.logoId) : undefined,
                });
              }
            }),
            catchError(() => {
              this.toast.showError('errors.failedToUpdateCategory');
              return of(null);
            }),
            finalize(() => (this.isSaving = false)),
          )
          .subscribe();
      } else {
        const command = new CreateCategoryCommand();
        command.nameEn = this.form.value.nameEn;
        command.nameAr = this.form.value.nameAr;
        command.descriptionEn = this.form.value.descriptionEn;
        command.descriptionAr = this.form.value.descriptionAr;
        command.logoId = logoId ? (logoId as any) : undefined;

        this.apiClient
          .createCategory(command)
          .pipe(
            tap((res) => {
              this.toast.showSuccess(
                res.message ? res.message : 'categories.messages.createSuccess',
              );
              if (res.category) {
                this.saved.emit({
                  id: res.category.id!,
                  nameEn: res.category.nameEn!,
                  nameAr: res.category.nameAr,
                  descriptionEn: res.category.descriptionEn,
                  descriptionAr: res.category.descriptionAr,
                  logoUrl: res.category.logoUrl,
                  logoId: res.category.logoId ? Number(res.category.logoId) : undefined,
                });
              }
            }),
            catchError(() => {
              this.toast.showError('errors.failedToCreateCategory');
              return of(null);
            }),
            finalize(() => (this.isSaving = false)),
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
