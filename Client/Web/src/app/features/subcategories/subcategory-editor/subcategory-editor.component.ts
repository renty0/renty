import {
  Component,
  inject,
  OnInit,
  ViewChild,
  input,
  output,
  computed,
  signal,
  effect,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatSelectModule } from '@angular/material/select';
import { MatOptionModule } from '@angular/material/core';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { catchError, finalize, of, tap } from 'rxjs';
import { ImageUploaderComponent } from '../../../shared/components/image-uploader/image-uploader.component';
import { ToastService } from '../../../shared/services/toast.service';
import {
  CategoriesClient,
  SubcategoriesClient,
  CreateSubcategoryCommand,
  UpdateSubcategoryCommand,
  ProductCategoryDto,
  ProductSubcategoryDto,
} from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent } from '../../../shared/components/input/input';

@Component({
  selector: 'app-subcategory-editor',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TranslateModule,
    MatIconModule,
    MatSelectModule,
    MatOptionModule,
    ImageUploaderComponent,
    LoadingButtonComponent,
    InputComponent,
  ],
  templateUrl: './subcategory-editor.component.html',
  styleUrl: './subcategory-editor.component.scss',
})
export class SubcategoryEditorComponent implements OnInit {
  private fb = inject(FormBuilder);
  private apiClient = inject(SubcategoriesClient);
  private categoriesClient = inject(CategoriesClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  id = input<number | null>(null);
  saved = output<ProductSubcategoryDto>();
  cancelled = output<void>();

  @ViewChild('logoUploader') logoUploader!: ImageUploaderComponent;

  form: FormGroup;
  isEditMode = computed(() => !!this.id());
  isLoading = signal(false);
  isSaving = signal(false);
  categories = signal<ProductCategoryDto[]>([]);
  isLoadingCategories = signal(false);
  categoryOptions = computed(() =>
    this.categories().map((c) => ({ name: c.nameEn || c.nameAr || '', code: c.id! })),
  );

  constructor() {
    this.form = this.fb.group({
      nameAr: ['', [Validators.required, Validators.maxLength(100)]],
      nameEn: ['', [Validators.required, Validators.maxLength(100)]],
      categoryId: [null, [Validators.required]],
      descAr: ['', [Validators.maxLength(500)]],
      descEn: ['', [Validators.maxLength(500)]],
      logoId: [null],
    });

    // Refetch subcategory when id changes
    effect(() => {
      const id = this.id();
      if (id) {
        this.loadSubcategory(id);
      } else {
        this.form.reset();
        if (this.logoUploader) {
          this.logoUploader.imageUrl = null;
          this.logoUploader.fileId = null;
        }
      }
    });
  }

  ngOnInit() {
    this.loadCategories();
  }

  private loadCategories() {
    this.isLoadingCategories.set(true);
    this.categoriesClient
      .getCategories(1, 1000)
      .pipe(
        tap((res) => {
          this.categories.set(res.data || []);
        }),
        catchError((err) => {
          this.toast.showError('errors.failedToLoadCategories');
          return of({ items: [] } as any);
        }),
        finalize(() => this.isLoadingCategories.set(false)),
      )
      .subscribe();
  }

  private loadSubcategory(id: number) {
    this.isLoading.set(true);
    this.apiClient
      .getSubcategoryById(id)
      .pipe(
        tap((response) => {
          const subcategory = response.data;
          if (subcategory) {
            this.form.patchValue({
              nameAr: subcategory.nameAr,
              nameEn: subcategory.nameEn,
              descAr: subcategory.descAr,
              descEn: subcategory.descEn,
              categoryId: subcategory.categoryId,
              logoId: subcategory.logoId,
            });

            if (this.logoUploader) {
              this.logoUploader.imageUrl = subcategory.logoUrl || null;
              this.logoUploader.fileId = subcategory.logoId?.toString() || null;
            }
          }
        }),
        catchError((err) => {
          console.error('Failed to load subcategory', err);
          this.toast.showError('errors.failedToLoadSubcategory');
          this.cancelled.emit();
          return of(null);
        }),
        finalize(() => this.isLoading.set(false)),
      )
      .subscribe();
  }

  async submit() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.isSaving.set(true);

    try {
      const uploadSuccess = (await this.logoUploader?.uploadFileAsync()) ?? true;
      if (!uploadSuccess) {
        this.toast.showError('errors.failedToUploadLogo');
        this.isSaving.set(false);
        return;
      }

      const formValue = this.form.value;
      const logoId = this.logoUploader?.fileId ? this.logoUploader.fileId : null;
      const idValue = this.id();

      if (this.isEditMode() && idValue) {
        const command = new UpdateSubcategoryCommand({
          id: idValue,
          nameAr: formValue.nameAr,
          nameEn: formValue.nameEn,
          descAr: formValue.descAr,
          descEn: formValue.descEn,
          categoryId: formValue.categoryId,
          logoId: logoId || undefined,
        });

        this.apiClient
          .updateSubcategory(idValue, command)
          .pipe(
            tap((res) => {
              if (res.error) {
                this.toast.showError(res.messages?.[0] || 'errors.unknownError');
              } else {
                this.toast.showSuccess(res.messages?.[0] || 'subcategories.messages.updateSuccess');
                if (res.data) {
                  this.saved.emit(res.data);
                } else {
                  this.saved.emit({ ...formValue, id: idValue, logoId });
                }
              }
            }),
            catchError((err) => {
              this.toast.showError(err.message || 'errors.unknownError');
              return of(null);
            }),
            finalize(() => this.isSaving.set(false)),
          )
          .subscribe();
      } else {
        const command = new CreateSubcategoryCommand({
          nameAr: formValue.nameAr,
          nameEn: formValue.nameEn,
          descAr: formValue.descAr,
          descEn: formValue.descEn,
          categoryId: formValue.categoryId,
          logoId: logoId || undefined,
        });

        this.apiClient
          .createSubcategory(command)
          .pipe(
            tap((res) => {
              if (res.error && res.messages) {
                this.toast.showError(res.messages?.[0]);
              } else {
                if (res.data) {
                  this.saved.emit(res.data);
                }
              }
            }),
            catchError((err) => {
              console.error('Create failed', err);
              this.toast.showError(err.message || 'errors.unknownError');
              return of(null);
            }),
            finalize(() => this.isSaving.set(false)),
          )
          .subscribe();
      }
    } catch (error) {
      this.isSaving.set(false);
      console.error(error);
      this.toast.showError('errors.unknownError');
    }
  }
}
