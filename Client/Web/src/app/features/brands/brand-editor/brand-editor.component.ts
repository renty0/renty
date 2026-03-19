import { Component, inject, OnInit, ViewChild, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule, TranslatePipe, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { ImageUploaderComponent } from '../../../shared/components/image-uploader/image-uploader.component';
import { ToastService } from '../../../shared/services/toast.service';
import {
  BrandsClient,
  CreateBrandCommand,
  UpdateBrandCommand,
  BrandDto,
} from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent } from '../../../shared/components/input/input';

@Component({
  selector: 'app-brand-editor',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatIconModule,
    ImageUploaderComponent,
    LoadingButtonComponent,
    TranslatePipe,
    InputComponent,
  ],
  templateUrl: './brand-editor.component.html',
  styleUrl: './brand-editor.component.scss',
})
export class BrandEditorComponent implements OnInit {
  private fb = inject(FormBuilder);
  private apiClient = inject(BrandsClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  @Input() id: number | null = null;
  @Output() saved = new EventEmitter<BrandDto>();
  @Output() cancelled = new EventEmitter<void>();

  @ViewChild('logoUploader') logoUploader!: ImageUploaderComponent;

  form: FormGroup;
  isEditMode = false;
  brandId: number | null = null;
  isLoading = false;
  isSaving = false;

  constructor() {
    this.form = this.fb.group({
      nameAr: ['', [Validators.required, Validators.maxLength(100)]],
      nameEn: ['', [Validators.required, Validators.maxLength(100)]],
      descAr: ['', [Validators.maxLength(500)]],
      descEn: ['', [Validators.maxLength(500)]],
      logoId: [null],
    });
  }

  ngOnInit() {
    if (this.id) {
      this.isEditMode = true;
      this.brandId = this.id;
      this.loadBrand(this.brandId);
    }
  }

  private loadBrand(id: number) {
    this.isLoading = true;
    this.apiClient
      .getBrandById(id)
      .pipe(
        tap((res) => {
          if (res.data) {
            this.form.patchValue({
              nameAr: res.data.nameAr,
              nameEn: res.data.nameEn,
              descAr: res.data.descAr,
              descEn: res.data.descEn,
              logoId: res.data.logoId,
            });

            if (this.logoUploader) {
              this.logoUploader.imageUrl = res.data.logoUrl || null;
              this.logoUploader.fileId = res.data.logoId || null;
            }
          }
        }),
        finalize(() => (this.isLoading = false)),
        catchError(() => {
          this.toast.showError('brands.errors.failedToLoad');
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
        this.isSaving = false;
        return;
      }

      const logoId = this.logoUploader?.fileId;

      if (this.isEditMode && this.brandId) {
        const formValue = this.form.value;
        const command = new UpdateBrandCommand({
          id: this.brandId,
          nameAr: formValue.nameAr,
          nameEn: formValue.nameEn,
          descAr: formValue.descAr,
          descEn: formValue.descEn,
          logoId: logoId || undefined,
        });

        this.apiClient
          .updateBrand(this.brandId, command)
          .pipe(
            tap((res) => {
              if (!res.error) {
                if (res.data) {
                  this.saved.emit(res.data);
                }
              } else {
                this.toast.showError(res.messages?.[0] || 'brands.errors.failedToUpdate');
              }
            }),
            catchError(() => {
              this.toast.showError('brands.errors.failedToUpdate');
              return of(null);
            }),
            finalize(() => (this.isSaving = false)),
          )
          .subscribe();
      } else {
        const command = new CreateBrandCommand({
          nameAr: this.form.value.nameAr,
          nameEn: this.form.value.nameEn,
          descAr: this.form.value.descAr,
          descEn: this.form.value.descEn,
          logoId: logoId as any,
        });

        this.apiClient
          .createBrand(command)
          .pipe(
            tap((res) => {
              if (!res.error) {
                if (res.data) {
                  this.saved.emit(res.data);
                }
              } else {
                this.toast.showError(res.messages?.[0] || 'brands.errors.failedToCreate');
              }
            }),
            catchError(() => {
              this.toast.showError('brands.errors.failedToCreate');
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
