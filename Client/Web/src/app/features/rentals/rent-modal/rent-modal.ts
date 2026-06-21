import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { RentalsClient, CreateRentalRequest, ItemDetailDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent, SelectOption } from '../../../shared/components/input/input';

@Component({
  selector: 'app-rent-modal',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatButtonModule,
    MatCheckboxModule,
    MatIconModule,
    TranslateModule,
    LoadingButtonComponent,
    InputComponent
  ],
  templateUrl: './rent-modal.html',
  styleUrl: './rent-modal.scss'
})
export class RentModalComponent implements OnInit {
  private fb = inject(FormBuilder);
  private rentalsClient = inject(RentalsClient);
  private toast = inject(ToastService);
  private dialogRef = inject(MatDialogRef<RentModalComponent>);
  private router = inject(Router);
  public data = inject<{ item: ItemDetailDto }>(MAT_DIALOG_DATA);

  rentForm!: FormGroup;
  minDate = new Date();
  isSubmitting = signal(false);
  policyExpanded = signal(false);

  availablePricingTypes = computed(() => {
    return this.data.item?.pricing?.map(p => p.pricingType) || ['daily'];
  });

  pricingTypeOptions = computed<SelectOption[]>(() =>
    (this.data.item?.pricing ?? [{ pricingType: 'daily' }]).map(p => ({
      name: 'rentals.' + (p.pricingType ?? 'daily').toLowerCase(),
      code: p.pricingType ?? 'daily'
    }))
  );


  rentalPrice = signal(0);
  depositAmount = signal(this.data.item?.defaultDeposit || 0);
  expertReviewFee = signal(0);
  totalAmount = computed(() => {
    return this.rentalPrice() + this.depositAmount() + this.expertReviewFee();
  });

  ngOnInit() {
    this.rentForm = this.fb.group({
      startDate: [null, Validators.required],
      endDate: [null, Validators.required],
      pricingType: [this.availablePricingTypes()[0] || 'daily', Validators.required],
      desiredDeliveryDate: [null],
      negotiatedDeliveryDate: [null],
      notes: [''],
      requestExpertReview: [false]
    });

    this.rentForm.valueChanges.subscribe(() => {
      this.calculatePrice();
    });
  }

  calculatePrice() {
    this.expertReviewFee.set(this.rentForm.value.requestExpertReview ? 100 : 0);

    const { startDate, endDate, pricingType } = this.rentForm.value;
    if (!startDate || !endDate || !pricingType) {
      this.rentalPrice.set(0);
      return;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    const diffTime = Math.abs(end.getTime() - start.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    const pricing = this.data.item?.pricing?.find(p => p.pricingType === pricingType);
    if (!pricing) {
      this.rentalPrice.set(0);
      return;
    }

    let price = 0;
    if (pricingType === 'weekly') {
      price = (pricing.price || 0) * Math.ceil(diffDays / 7);
    } else if (pricingType === 'monthly') {
      price = (pricing.price || 0) * Math.ceil(diffDays / 30);
    } else {
      price = (pricing.price || 0) * diffDays;
    }

    this.rentalPrice.set(price);
  }

  onSubmit() {
    if (this.rentForm.invalid) return;

    this.isSubmitting.set(true);
    const formValue = this.rentForm.value;

    const command = new CreateRentalRequest({
      itemId: this.data.item.id!,
      startDate: formValue.startDate,
      endDate: formValue.endDate,
      pricingType: formValue.pricingType.toLowerCase(),
      notes: formValue.notes || undefined,
      requestExpertReview: formValue.requestExpertReview || false
    }) as any;

    this.rentalsClient.createRental(command).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] || 'rentals.error');
          this.isSubmitting.set(false);
        } else {
          this.toast.showSuccess('rentals.success');
          this.dialogRef.close(true);
          this.router.navigate(['/my-rentals']);
        }
      },
      error: (err) => {
        console.error('Rental creation failed', err);
        this.toast.showError('rentals.error');
        this.isSubmitting.set(false);
      }
    });
  }

  onCancel() {
    this.dialogRef.close(false);
  }
}
