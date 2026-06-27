import { Component, inject, OnInit, signal, Input, Output, EventEmitter, computed, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';

import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { InputComponent } from '../../../shared/components/input/input';
import { MultiImageUploaderComponent, UploadedImage } from '../../../shared/components/multi-image-uploader/multi-image-uploader.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { MapComponent } from '../../../shared/components/map/map.component';
import { ItemsClient, SubcategoriesClient, CreateItemCommand, CreateItemPricingCommand, CreateItemImageCommand, UpdateItemCommand, CategoriesClient, BrandsClient, CreateBrandCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { catchError, finalize, of, tap } from 'rxjs';
import { ITEM_TYPE_OPTIONS, ITEM_CONDITION_OPTIONS, EGYPT_GOVERNORATES } from './items-editor.constants';
import { LocalizationService } from '../../../core/services/localization.service';

@Component({
  selector: 'app-items-editor-page',
  standalone: true,
  imports: [ReactiveFormsModule, RouterModule, TranslateModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule, InputComponent, MultiImageUploaderComponent, HeaderSectionComponent, LoadingButtonComponent, MapComponent],
  templateUrl: './items-editor-page.component.html',
  styleUrl: './items-editor-page.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ItemsEditorPageComponent implements OnInit {
  private fb = inject(FormBuilder);
  private itemsClient = inject(ItemsClient);
  private subcategoriesClient = inject(SubcategoriesClient);
  private categoriesClient = inject(CategoriesClient);
  private brandsClient = inject(BrandsClient);
  private toast = inject(ToastService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private localization = inject(LocalizationService);
  private authService = inject(AuthService);
  private cdr = inject(ChangeDetectorRef);

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
  isLoading = signal(false);
  isSaving = signal(false);

  subcategories = computed(() => {
    const catId = this.selectedCategoryId();
    const lang = this.localization.language();
    if (!catId) return [];
    return this.allSubcategories()
      .filter((s) => s.categoryId === catId)
      .map((s) => ({
        name: lang === 'ar' ? (s.nameAr || s.nameEn) : (s.nameEn || s.nameAr),
        code: s.code,
      }));
  });
  allSubcategories = signal<{ nameAr: string; nameEn: string; code: number; categoryId?: number }[]>([]);
  selectedCategoryId = signal<number | null>(null);

  categories = computed(() => {
    const lang = this.localization.language();
    return this.allCategories().map((c) => ({
      name: lang === 'ar' ? (c.nameAr || c.nameEn) : (c.nameEn || c.nameAr),
      code: c.code,
    }));
  });
  allCategories = signal<{ nameAr: string; nameEn: string; code: number }[]>([]);

  brands = computed(() => {
    const lang = this.localization.language();
    const list = this.allBrands().map((b) => ({
      name: lang === 'ar' ? (b.nameAr || b.nameEn) : (b.nameEn || b.nameAr),
      code: b.code,
    }));
    return [
      ...list,
      { name: lang === 'ar' ? 'أخرى (ماركة غير مدرجة)' : 'Other (Brand not listed)', code: -1 }
    ];
  });
  allBrands = signal<{ nameAr: string; nameEn: string; code: number }[]>([]);

  uploadedImages: UploadedImage[] = [];

  readonly typeOptions = ITEM_TYPE_OPTIONS;
  readonly conditionOptions = ITEM_CONDITION_OPTIONS;
  readonly governorateOptions = EGYPT_GOVERNORATES;
  readonly availableForOptions = [
    { name: 'products.rentOnly', code: 'rent' },
    { name: 'products.saleOnly', code: 'sale' },
    { name: 'products.rentAndSale', code: 'both' }
  ];

  constructor() {
    this.initForm();
  }

  ngOnInit() {
    this.loadSubcategories();
    this.loadCategories();
    this.loadBrands();

    const categoryControl = this.form.get('categoryId');
    const subcategoryControl = this.form.get('subcategoryId');

    if (!categoryControl?.value) subcategoryControl?.disable();
    categoryControl?.valueChanges.subscribe((catId) => {
      this.selectedCategoryId.set(catId);
      if (catId) subcategoryControl?.enable();
      else {
        subcategoryControl?.disable();
        subcategoryControl?.setValue(null);
      }

      const currentSubId = subcategoryControl?.value;
      if (currentSubId) {
        const sub = this.allSubcategories().find((s) => s.code === currentSubId);
        if (sub && sub.categoryId !== catId) subcategoryControl?.setValue(null);
      }
    });

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
      this.form.patchValue({
        availableFor: 'rent',
        defaultDeposit: 0,
        dailyPrice: null,
        weeklyPrice: 0,
        monthlyPrice: 0,
        salePrice: null
      });
    }
  }

  private initForm() {
    this.form = this.fb.group({
      titleAr: ['', [Validators.required, Validators.maxLength(200)]],
      titleEn: ['', [Validators.required, Validators.maxLength(200)]],
      descAr: ['', [Validators.maxLength(1000)]],
      descEn: ['', [Validators.maxLength(1000)]],
      type: ['standard'],
      condition: ['good'],
      availableFor: ['rent'],
      salePrice: [null],
      defaultDeposit: [0, [Validators.required, Validators.min(0)]],
      dailyPrice: [null, [Validators.required, Validators.min(0.01)]],
      weeklyPrice: [0, [Validators.min(0)]],
      monthlyPrice: [0, [Validators.min(0)]],
      location: [''],
      city: [''],
      lat: [null],
      lng: [null],
      subcategoryId: [null, [Validators.required]],
      categoryId: [null],
      brandId: [null],
      newBrandNameAr: [''],
      newBrandNameEn: [''],
    });

    this.form.get('brandId')?.valueChanges.subscribe(val => {
      const nameArCtrl = this.form.get('newBrandNameAr');
      const nameEnCtrl = this.form.get('newBrandNameEn');
      
      if (val === -1) {
        nameArCtrl?.setValidators([Validators.required, Validators.maxLength(100)]);
        nameEnCtrl?.setValidators([Validators.required, Validators.maxLength(100)]);
      } else {
        nameArCtrl?.clearValidators();
        nameEnCtrl?.clearValidators();
      }
      nameArCtrl?.updateValueAndValidity();
      nameEnCtrl?.updateValueAndValidity();
    });

    this.form.get('availableFor')?.valueChanges.subscribe(val => {
      const dailyCtrl = this.form.get('dailyPrice');
      const saleCtrl = this.form.get('salePrice');
      
      if (val === 'rent' || val === 'both') {
        dailyCtrl?.setValidators([Validators.required, Validators.min(0.01)]);
      } else {
        dailyCtrl?.clearValidators();
        dailyCtrl?.setValue(null, { emitEvent: false });
        dailyCtrl?.markAsPristine();
        dailyCtrl?.markAsUntouched();
      }
      
      if (val === 'sale' || val === 'both') {
        saleCtrl?.setValidators([Validators.required, Validators.min(0.01)]);
      } else {
        saleCtrl?.clearValidators();
        saleCtrl?.setValue(null, { emitEvent: false });
        saleCtrl?.markAsPristine();
        saleCtrl?.markAsUntouched();
      }
      
      dailyCtrl?.updateValueAndValidity();
      saleCtrl?.updateValueAndValidity();
    });
  }
  private loadSubcategories() {
    this.subcategoriesClient
      .getSubcategories(1, 1000)
      .pipe(
        tap((res) => {
          if (res.data) {
            const options = res.data.map((s) => ({
              nameAr: s.nameAr || '',
              nameEn: s.nameEn || '',
              code: s.id ?? 0,
              categoryId: s.categoryId,
            }));
            this.allSubcategories.set(options);
          }
        }),
        catchError((err) => of(null))
      )
      .subscribe();
  }
  private loadCategories() {
    this.categoriesClient
      .getCategories(1, 1000)
      .pipe(
        tap((res) => {
          if (res.data) {
            const options = res.data.map((s) => ({
              nameAr: s.nameAr || '',
              nameEn: s.nameEn || '',
              code: s.id ?? 0,
            }));
            this.allCategories.set(options);
          }
        }),
        catchError((err) => of(null))
      )
      .subscribe();
  }
  private loadBrands() {
    this.brandsClient
      .getBrands(1, 1000)
      .pipe(
        tap((res) => {
          if (res.data) {
            const options = res.data.map((s) => ({
              nameAr: s.nameAr || '',
              nameEn: s.nameEn || '',
              code: s.id ?? 0,
            }));
            this.allBrands.set(options);
          }
        }),
        catchError((err) => of(null))
      )
      .subscribe();
  }
  private loadItem(id: string) {
    this.isLoading.set(true);
    this.itemsClient
      .getItemById(id)
      .pipe(
        tap((res) => {
          if (res.error) {
            this.toast.showError(res.messages?.[0] ?? 'errors.failedToLoadItemDetails');
            const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
            this.router.navigate(target);
            return;
          }

          const item = res.data;
          if (item) {
            const currentUserId = this.authService.getCurrentUserId();
            const isOwner = currentUserId !== null && item.owner?.id === currentUserId;
            if (!isOwner) {
              this.toast.showError('errors.unauthorizedToEdit');
              const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
              this.router.navigate(target);
              return;
            }

            const hasRent = item.pricing?.some((p: any) => p.pricingType === 'daily' || p.pricingType === 'weekly' || p.pricingType === 'monthly');
            const isSale = item.isForSale;
            let availableFor = 'rent';
            if (hasRent && isSale) availableFor = 'both';
            else if (isSale) availableFor = 'sale';
            
            this.form.patchValue({
              titleAr: item.titleAr,
              titleEn: item.titleEn,
              descAr: item.descAr,
              descEn: item.descEn,
              type: item.type,
              condition: item.condition,
              availableFor: availableFor,
              salePrice: item.salePrice ?? 0,
              defaultDeposit: item.defaultDeposit,
              dailyPrice: item.pricing?.find((p: any) => p.pricingType === 'daily')?.price ?? 0,
              weeklyPrice: item.pricing?.find((p: any) => p.pricingType === 'weekly')?.price ?? 0,
              monthlyPrice: item.pricing?.find((p: any) => p.pricingType === 'monthly')?.price ?? 0,
              location: item.location,
              city: item.city,
              lat: item.lat,
              lng: item.lng,
              subcategoryId: item.subcategory?.id ?? null,
              categoryId: item.category?.id ?? null,
              brandId: item.brand?.id ?? null,
            });

            if (item.category?.id) {
              this.selectedCategoryId.set(item.category.id);
              this.form.get('subcategoryId')?.enable();
            }

            if (item.images) {
              this.uploadedImages = item.images.map((img, idx) => ({
                id: img.id || null,
                mediaFileId: img.id, // In this API, the image ID returned in DTO is used as the imageId for commands
                imageUrl: img.imageUrl ?? '',
                isPrimary: img.isPrimary ?? false,
                displayOrder: idx,
                isUploading: false,
              }));
            }
          }
        }),
        catchError(() => {
          this.toast.showError('errors.failedToLoadItemDetails');
          const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
          this.router.navigate(target);
          return of(null);
        }),
        finalize(() => { this.isLoading.set(false); this.cdr.markForCheck(); }),
      )
      .subscribe();
  }
  onSubmit() {
    if (this.form.invalid) return;
    this.isSaving.set(true);

    const brandIdCtrl = this.form.get('brandId');
    if (brandIdCtrl?.value === -1) {
      const nameAr = this.form.get('newBrandNameAr')?.value;
      const nameEn = this.form.get('newBrandNameEn')?.value;

      const cmd = new CreateBrandCommand({
        nameAr: nameAr,
        nameEn: nameEn,
      });

      this.brandsClient.createBrand(cmd)
        .subscribe({
          next: (res) => {
            if (res.error || !res.data) {
              this.toast.showError(res.messages?.[0] ?? 'brands.errors.failedToCreate');
              this.isSaving.set(false);
              this.cdr.markForCheck();
            } else {
              const newBrandId = res.data.id;
              this.form.patchValue({ brandId: newBrandId });

              if (this.isEditMode && this.itemId) this.updateItem();
              else this.createItem();
            }
          },
          error: () => {
            this.toast.showError('brands.errors.failedToCreate');
            this.isSaving.set(false);
            this.cdr.markForCheck();
          }
        });
    } else {
      if (this.isEditMode && this.itemId) this.updateItem();
      else this.createItem();
    }
  }
  private buildImages(): CreateItemImageCommand[] {
    return this.uploadedImages
      .filter(img => img.mediaFileId || img.id)
      .map(
        (img) => new CreateItemImageCommand({
          imageId: img.mediaFileId ?? img.id?.toString(),
          isPrimary: img.isPrimary,
        }),
      );
  }
  private createItem() {
    const v = this.form.value;
    const cmd = new CreateItemCommand({
      titleAr: v.titleAr,
      titleEn: v.titleEn,
      descAr: v.descAr,
      descEn: v.descEn,
      type: v.type,
      condition: v.condition,
      defaultDeposit: v.defaultDeposit,
      location: v.location ?? null,
      city: v.city ?? null,
      lat: v.lat ?? null,
      lng: v.lng ?? null,
      subcategoryId: v.subcategoryId ?? null,
      categoryId: v.categoryId ?? null,
      brandId: v.brandId ?? null,
      isForSale: v.availableFor === 'sale' || v.availableFor === 'both',
      salePrice: (v.availableFor === 'sale' || v.availableFor === 'both') ? v.salePrice : null,
      pricing: (v.availableFor === 'rent' || v.availableFor === 'both') ? [
        new CreateItemPricingCommand({ pricingType: 'daily', price: v.dailyPrice }),
        ...(v.weeklyPrice > 0 ? [new CreateItemPricingCommand({ pricingType: 'weekly', price: v.weeklyPrice })] : []),
        ...(v.monthlyPrice > 0 ? [new CreateItemPricingCommand({ pricingType: 'monthly', price: v.monthlyPrice })] : []),
      ] : [],
      images: this.buildImages(),
    });
    this.itemsClient.createItem(cmd)
      .pipe(
        tap((res) => {
          if (res.error) {
            this.toast.showError(res.messages?.[0] ?? 'products.createFailed');
          } else {
            this.toast.showSuccess(res.messages?.[0] || 'products.createSuccess');
            this.saved.emit();
            if (this.saved.observed === false) {
              const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
              this.router.navigate(target);
            }
          }
        }),
        catchError(() => {
          this.toast.showError('products.createFailed');
          return of(null);
        }),
        finalize(() => { this.isSaving.set(false); this.cdr.markForCheck(); }),
      )
      .subscribe();
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
      location: v.location ?? null,
      city: v.city ?? null,
      lat: v.lat ?? null,
      lng: v.lng ?? null,
      subcategoryId: v.subcategoryId ?? null,
      categoryId: v.categoryId ?? null,
      brandId: v.brandId ?? null,
      isForSale: v.availableFor === 'sale' || v.availableFor === 'both',
      salePrice: (v.availableFor === 'sale' || v.availableFor === 'both') ? v.salePrice : null,
      pricing: (v.availableFor === 'rent' || v.availableFor === 'both') ? [
        new CreateItemPricingCommand({ pricingType: 'daily', price: v.dailyPrice }),
        ...(v.weeklyPrice > 0 ? [new CreateItemPricingCommand({ pricingType: 'weekly', price: v.weeklyPrice })] : []),
        ...(v.monthlyPrice > 0 ? [new CreateItemPricingCommand({ pricingType: 'monthly', price: v.monthlyPrice })] : []),
      ] : [],
      images: this.buildImages(),
    });

    this.itemsClient
      .updateItem(this.itemId!, cmd)
      .pipe(
        tap((res) => {
          if (res.error) {
            this.toast.showError(res.messages?.[0] ?? 'products.updateFailed');
          } else {
            this.toast.showSuccess(res.messages?.[0] || 'products.updateSuccess');
            this.saved.emit();
            if (this.saved.observed === false) {
              const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
              this.router.navigate(target);
            }
          }
        }),
        catchError(() => {
          this.toast.showError('products.updateFailed');
          return of(null);
        }),
        finalize(() => { this.isSaving.set(false); this.cdr.markForCheck(); }),
      )
      .subscribe();
  }

  cancel() {
    this.cancelled.emit();
    if (this.cancelled.observed === false) {
      const target = this.authService.isAdmin() ? ['/items'] : ['/my-items'];
      this.router.navigate(target);
    }
  }
}
