import { Component, inject, OnInit, signal, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

import { InputComponent } from '../../../shared/components/input/input';
import { MultiImageUploaderComponent, UploadedImage } from '../../../shared/components/multi-image-uploader/multi-image-uploader.component';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

import { ProductsClient, SubcategoriesClient, CreateProductCommand, UpdateProductCommand, ProductImageDto } from '../../../core/api/api-client';
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
        LoadingButtonComponent
    ],
    templateUrl: './product-editor-page.component.html',
    styleUrl: './product-editor-page.component.scss'
})
export class ProductEditorPageComponent implements OnInit {
    private fb = inject(FormBuilder);
    private productsClient = inject(ProductsClient);
    private subcategoriesClient = inject(SubcategoriesClient);
    private toast = inject(ToastService);
    private router = inject(Router);
    private route = inject(ActivatedRoute);

    @Input('productId') set setProductId(val: number | undefined | null) {
        if (val !== undefined && val !== null) {
            this.productId = val;
            this.isEditMode = !!val;
            if (this.isEditMode) {
                this.loadProduct(this.productId!);
            } else {
                this.resetForm();
            }
        }
    }

    @Output() saved = new EventEmitter<void>();
    @Output() cancelled = new EventEmitter<void>();

    form!: FormGroup;
    isEditMode = false;
    productId: number | null = null;
    isLoading = false;
    isSaving = false;

    subcategories = signal<{ name: string; code: number }[]>([]);
    uploadedImages: UploadedImage[] = [];

    constructor() {
        this.initForm();
    }

    ngOnInit() {
        this.loadSubcategories();
        if (this.productId === null) {
            this.route.params.subscribe(params => {
                if (params['id']) {
                    this.productId = +params['id'];
                    this.isEditMode = true;
                    this.loadProduct(this.productId);
                }
            });
        }
    }

    private resetForm() {
        if (this.form) {
            this.form.reset();
            this.uploadedImages = [];
            this.form.patchValue({ productCost: 0, productPrice: 0 });
        }
    }

    private initForm() {
        this.form = this.fb.group({
            productSku: ['', [Validators.required, Validators.maxLength(50)]],
            productName: ['', [Validators.required, Validators.maxLength(200)]],
            modelName: ['', [Validators.maxLength(100)]],
            productDescription: ['', [Validators.maxLength(1000)]],
            productColor: ['', [Validators.maxLength(50)]],
            productStyle: ['', [Validators.maxLength(50)]],
            productCost: [0, [Validators.required, Validators.min(0)]],
            productPrice: [0, [Validators.required, Validators.min(0.01)]],
            skuType: ['', [Validators.maxLength(50)]],
            discountPrice: [null],
            subcategoryId: [null, [Validators.required]],
        });
    }

    private loadSubcategories() {
        this.subcategoriesClient.getSubcategories(undefined, 1, 1000).subscribe({
            next: (res) => {
                if (res.subcategories?.items) {
                    console.log(res);
                    
                    const options = res.subcategories.items.map(s => ({
                        name: `${s.subcategoryName} (${s.categoryName})`,
                        code: s.id || 0
                    }));
                    this.subcategories.set(options);
                }
            }
        });
    }

    private loadProduct(id: number) {
        this.isLoading = true;
        this.productsClient.getProductById(id).subscribe({
            next: (res: any) => {
                if (res && res.success === false) {
                    this.toast.showError(res.message || 'Failed to load product details');
                    this.router.navigate(['/products']);
                    this.isLoading = false;
                    return;
                }

                const p = res?.product || res;
                if (p) {
                    this.form.patchValue({
                        productSku: p.productSku,
                        productName: p.productName,
                        modelName: p.modelName,
                        productDescription: p.productDescription,
                        productColor: p.productColor,
                        productStyle: p.productStyle,
                        productCost: p.productCost,
                        productPrice: p.productPrice,
                        skuType: p.skuType,
                        discountPrice: p.discountPrice,
                        subcategoryId: p.subcategoryId || p.productSubcategoryId // Handle possible name mismatch
                    });

                    // Map images
                    if (p.images) {
                        this.uploadedImages = p.images.map((img: ProductImageDto) => ({
                            id: img.id,
                            imageUrl: img.imageUrl,
                            isPrimary: img.isPrimary,
                            displayOrder: img.displayOrder,
                            isUploading: false
                        })).sort((a: UploadedImage, b: UploadedImage) => a.displayOrder - b.displayOrder);
                    }
                }
                this.isLoading = false;
            },
            error: () => {
                this.toast.showError('Failed to load product details');
                this.isLoading = false;
                this.router.navigate(['/products']);
            }
        });
    }

    onSubmit() {
        console.log('valid ' + this.form.valid);
        
        if (this.form.invalid) return;

        this.isSaving = true;
        const formValue = this.form.value;
        console.log('formValue ' + formValue);
        console.log('isEditMode ' + this.isEditMode);
        console.log('productId ' + this.productId);
        
        if (this.isEditMode && this.productId) {
            this.updateProduct(formValue);
        } else {
            this.createProduct(formValue);
        }
    }

    private createProduct(formValue: any) {
        const sortedImages = [...this.uploadedImages].sort((a, b) => {
            if (a.isPrimary) return -1;
            if (b.isPrimary) return 1;
            return a.displayOrder - b.displayOrder;
        });

        const imageUrls = sortedImages.map(img => img.imageUrl);

        const command = new CreateProductCommand({
            ...formValue,
            imageUrls: imageUrls
        });

        this.productsClient.createProduct(command).subscribe({
            next: (res: any) => {
                // If it returns void, res might be null, which counts as success here.
                if (res && res.success === false) {
                    this.toast.showError(res.message || 'Failed to create product');
                } else {
                    this.toast.showSuccess('Product created successfully');
                    this.saved.emit();
                    if (this.saved.observers.length === 0) {
                        this.router.navigate(['/products']);
                    }
                }
                this.isSaving = false;
            },
            error: () => {
                this.toast.showError('An error occurred while creating product');
                this.isSaving = false;
            }
        });
    }

    private updateProduct(formValue: any) {
        const images: ProductImageDto[] = this.uploadedImages.map((img, index) => {
            return new ProductImageDto({
                id: img.id && img.id > 0 ? img.id : 0,
                imageUrl: img.imageUrl,
                isPrimary: img.isPrimary,
                displayOrder: index
            });
        });

        const command = new UpdateProductCommand({
            id: this.productId!,
            ...formValue,
            images: images
        });

        this.productsClient.updateProduct(this.productId!, command).subscribe({
            next: (res: any) => {
                if (res && res.success === false) {
                    this.toast.showError(res.message || 'Failed to update product');
                } else {
                    this.toast.showSuccess('Product updated successfully');
                    this.saved.emit();
                    if (this.saved.observers.length === 0) {
                        this.router.navigate(['/products']);
                    }
                }
                this.isSaving = false;
            },
            error: () => {
                this.toast.showError('An error occurred while updating product');
                this.isSaving = false;
            }
        });
    }

    cancel() {
        this.cancelled.emit();
        if (this.cancelled.observers.length === 0) {
            this.router.navigate(['/products']);
        }
    }
}
