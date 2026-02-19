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
import { CategoriesClient, SubcategoriesClient, CreateSubcategoryCommand, UpdateSubcategoryCommand, ProductCategoryDto } from '../../../core/api/api-client';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent } from '../../../shared/components/input/input';

@Component({
  selector: 'app-subcategory-editor',
  standalone: true,
  imports: [ CommonModule, ReactiveFormsModule, TranslateModule, MatIconModule, MatSelectModule, MatOptionModule, ImageUploaderComponent, LoadingButtonComponent, InputComponent ],
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
  saved = output<any>();
  cancelled = output<void>();

  @ViewChild('logoUploader') logoUploader!: ImageUploaderComponent;

  form: FormGroup;
  isEditMode = computed(() => !!this.id());
  isLoading = signal(false);
  isSaving = signal(false);
  categories = signal<ProductCategoryDto[]>([]);
  isLoadingCategories = signal(false);
  categoryOptions = computed(() =>
    this.categories().map((c) => ({ name: c.nameEn || '', code: c.id! })),
  );

  constructor() {
    this.form = this.fb.group({
      nameEn: ['', [Validators.required, Validators.maxLength(100)]],
      nameAr: ['', [Validators.maxLength(100)]],
      categoryId: [null, [Validators.required]],
      descriptionEn: ['', [Validators.maxLength(500)]],
      descriptionAr: ['', [Validators.maxLength(500)]],
      logoId: [null, Validators.required],
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
          this.categories.set(res.items || []);
        }),
        catchError((err) => {
          console.error('Failed to load categories', err);
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
          const subcategory = response.subcategory;
          if (subcategory) {
            this.form.patchValue({
              nameEn: subcategory.nameEn,
              nameAr: subcategory.nameAr,
              descriptionEn: subcategory.descriptionEn,
              descriptionAr: subcategory.descriptionAr,
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
          nameEn: formValue.nameEn,
          nameAr: formValue.nameAr,
          descriptionEn: formValue.descriptionEn,
          descriptionAr: formValue.descriptionAr,
          categoryId: formValue.categoryId,
          logoId: logoId || '',
        });

        this.apiClient
          .updateSubcategory(idValue, command)
          .pipe(
            tap((res) => {
              this.toast.showSuccess(res.message || 'subcategories.messages.updateSuccess');
              if (res.subcategory) {
                this.saved.emit(res.subcategory);
              } else {
                this.saved.emit({ ...formValue, id: idValue, logoId });
              }
            }),
            catchError((err) => {
              console.error('Update failed', err);
              this.toast.showError(err.message || 'errors.unknownError');
              return of(null);
            }),
            finalize(() => this.isSaving.set(false)),
          )
          .subscribe();
      } else {
        const command = new CreateSubcategoryCommand({
          nameEn: formValue.nameEn,
          nameAr: formValue.nameAr,
          descriptionEn: formValue.descriptionEn,
          descriptionAr: formValue.descriptionAr,
          categoryId: formValue.categoryId,
          logoId: logoId || '',
        });

        this.apiClient
          .createSubcategory(command)
          .pipe(
            tap((res) => {
              this.toast.showSuccess(res.message || 'subcategories.messages.createSuccess');
              if (res.subcategory) {
                this.saved.emit(res.subcategory);
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
