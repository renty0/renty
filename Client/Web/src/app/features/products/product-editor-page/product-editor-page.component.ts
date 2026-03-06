import { Component, inject, OnInit, signal, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

import { InputComponent } from '../../../shared/components/input/input';
import {
  MultiImageUploaderComponent,
  UploadedImage,
} from '../../../shared/components/multi-image-uploader/multi-image-uploader.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

import {
  ItemsClient,
  SubcategoriesClient,
  CreateItemCommand,
  CreateItemPricingCommand,
  CreateItemImageCommand,
  UpdateItemCommand,
} from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
  selector: 'app-product-editor-page',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    TranslateModule,
    MatButtonModule,
    MatIconModule,
    InputComponent,
    MultiImageUploaderComponent,
    HeaderSectionComponent,
    LoadingButtonComponent,
  ],
  templateUrl: './product-editor-page.component.html',
  styleUrl: './product-editor-page.component.scss',
})
export class ProductEditorPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private itemsClient = inject(ItemsClient);
  private subcategoriesClient = inject(SubcategoriesClient);
  private toast = inject(ToastService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  // When used as a dialog/embedded component the itemId is a Guid string
  @Input('itemId') set setItemId(val: string | undefined | null) {
    if (val != null) {
      this.itemId = val;
      this.isEditMode = true;
      this.loadItem(val);
    } else {
      this.resetForm();
    }
  }

  @Output() saved = new EventEmitter<void>();
  @Output() cancelled = new EventEmitter<void>();

  form!: FormGroup;
  isEditMode = false;
  itemId: string | null = null;
  isLoading = false;
  isSaving = false;

  subcategories = signal<{ name: string; code: number }[]>([]);
  uploadedImages: UploadedImage[] = [];

  readonly typeOptions: { name: string; code: any }[] = [
    { name: 'Standard', code: 'standard' },
    { name: 'Premium', code: 'premium' },
  ];

  readonly conditionOptions: { name: string; code: any }[] = [
    { name: 'New', code: 'new' },
    { name: 'Like New', code: 'like_new' },
    { name: 'Good', code: 'good' },
    { name: 'Fair', code: 'fair' },
  ];

  /** Daily price (the primary pricing entry) — kept as a plain form control */
  constructor() {
    this.initForm();
  }

  ngOnInit() {
    this.loadSubcategories();
    // When used as a routed page, read the :id param
    if (this.itemId === null) {
      this.route.params.subscribe((params) => {
        if (params['id']) {
          this.itemId = params['id'];
          this.isEditMode = true;
          this.loadItem(this.itemId!);
        }
      });
    }
  }

  private resetForm() {
    if (this.form) {
      this.form.reset();
      this.uploadedImages = [];
      this.form.patchValue({ defaultDeposit: 0, dailyPrice: 0 });
    }
  }

  private initForm() {
    this.form = this.fb.group({
      titleAr: ['', [Validators.required, Validators.maxLength(200)]],
      titleEn: ['', [Validators.required, Validators.maxLength(200)]],
      descAr: ['', [Validators.maxLength(1000)]],
      descEn: ['', [Validators.maxLength(1000)]],
      type: ['standard'], // standard | premium
      condition: ['good'], // new | like_new | good | fair
      defaultDeposit: [0, [Validators.required, Validators.min(0)]],
      dailyPrice: [0, [Validators.required, Validators.min(0.01)]],
      location: [''],
      city: [''],
      subcategoryId: [null, [Validators.required]],
      categoryId: [null],
      brandId: [null],
    });
  }

  private loadSubcategories() {
    this.subcategoriesClient.getSubcategories(1, 1000).subscribe({
      next: (res) => {
        if (res.data) {
          const options = res.data.map((s) => ({
            name: `${s.nameEn || s.nameAr} (${s.categoryId})`, // Simplified for now, category name might be missing in flat subcategory list
            code: s.id ?? 0,
          }));
          this.subcategories.set(options);
        }
      },
    });
  }

  private loadItem(id: string) {
    this.isLoading = true;
    this.itemsClient.getItemById(id).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] ?? 'Failed to load item details');
          this.router.navigate(['/products']);
          this.isLoading = false;
          return;
        }

        const item = res.data;
        if (item) {
          this.form.patchValue({
            titleAr: item.titleAr,
            titleEn: item.titleEn,
            descAr: item.descAr,
            descEn: item.descEn,
            type: item.type,
            condition: item.condition,
            defaultDeposit: item.defaultDeposit,
            dailyPrice: item.pricing?.find((p) => p.pricingType === 'daily')?.price ?? 0,
            location: item.location,
            city: item.city,
            subcategoryId: item.subcategory?.id ?? null,
            categoryId: item.category?.id ?? null,
            brandId: item.brand?.id ?? null,
          });

          if (item.images) {
            this.uploadedImages = item.images.map((img, idx) => ({
              id: img.id ? parseInt(img.id, 10) : idx,
              imageUrl: img.imageUrl ?? '',
              isPrimary: img.isPrimary ?? false,
              displayOrder: idx,
              isUploading: false,
            }));
          }
        }
        this.isLoading = false;
      },
      error: () => {
        this.toast.showError('Failed to load item details');
        this.isLoading = false;
        this.router.navigate(['/products']);
      },
    });
  }

  onSubmit() {
    if (this.form.invalid) return;
    this.isSaving = true;
    if (this.isEditMode && this.itemId) {
      this.updateItem();
    } else {
      this.createItem();
    }
  }

  private buildImages(): CreateItemImageCommand[] {
    return this.uploadedImages.map(
      (img) => new CreateItemImageCommand({ imageId: img.id?.toString(), isPrimary: img.isPrimary }),
    );
  }

  private createItem() {
    const v = this.form.value;
    const cmd = new CreateItemCommand({
      productKey: 1,
      titleAr: v.titleAr,
      titleEn: v.titleEn,
      descAr: v.descAr,
      descEn: v.descEn,
      type: v.type,
      condition: v.condition,
      defaultDeposit: v.defaultDeposit,
      location: v.location || undefined,
      city: v.city || undefined,
      subcategoryId: v.subcategoryId ?? undefined,
      categoryId: v.categoryId ?? undefined,
      brandId: v.brandId ?? undefined,
      pricing: [new CreateItemPricingCommand({ pricingType: 'daily', price: v.dailyPrice })],
      images: this.buildImages(),
    });

    this.itemsClient.createItem(cmd).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] ?? 'Failed to create item');
        } else {
          this.toast.showSuccess(res.messages?.[0] || 'Item created successfully');
          this.saved.emit();
          if (this.saved.observed === false) {
            this.router.navigate(['/products']);
          }
        }
        this.isSaving = false;
      },
      error: () => {
        this.toast.showError('An error occurred while creating item');
        this.isSaving = false;
      },
    });
  }

  private updateItem() {
    const v = this.form.value;
    const cmd = new UpdateItemCommand({
      itemId: this.itemId!,
      titleAr: v.titleAr,
      titleEn: v.titleEn,
      descAr: v.descAr,
      descEn: v.descEn,
      type: v.type,
      condition: v.condition,
      defaultDeposit: v.defaultDeposit,
      location: v.location || undefined,
      city: v.city || undefined,
      subcategoryId: v.subcategoryId ?? undefined,
      categoryId: v.categoryId ?? undefined,
      brandId: v.brandId ?? undefined,
      pricing: [new CreateItemPricingCommand({ pricingType: 'daily', price: v.dailyPrice })],
      images: this.buildImages(),
    });

    this.itemsClient.updateItem(this.itemId!, cmd).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] ?? 'Failed to update item');
        } else {
          this.toast.showSuccess(res.messages?.[0] || 'Item updated successfully');
          this.saved.emit();
          if (this.saved.observed === false) {
            this.router.navigate(['/products']);
          }
        }
        this.isSaving = false;
      },
      error: () => {
        this.toast.showError('An error occurred while updating item');
        this.isSaving = false;
      },
    });
  }

  cancel() {
    this.cancelled.emit();
    if (this.cancelled.observed === false) {
      this.router.navigate(['/products']);
    }
  }
}
