import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { RentalsClient, CreateRentalCommand, ItemDetailDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

@Component({
  selector: 'app-rent-modal',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatDialogModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatSelectModule,
    MatCheckboxModule,
    MatIconModule,
    TranslateModule,
    LoadingButtonComponent
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

  availablePricingTypes = computed(() => {
    return this.data.item.pricing?.map(p => p.pricingType) || [];
  });

  rentalPrice = signal(0);
  depositAmount = signal(this.data.item.defaultDeposit || 0);
  totalAmount = computed(() => this.rentalPrice() + this.depositAmount());

  ngOnInit() {
    this.rentForm = this.fb.group({
      startDate: [null, Validators.required],
      endDate: [null, Validators.required],
      pricingType: [this.availablePricingTypes()[0] || 'daily', Validators.required],
      requiresExpert: [false]
    });

    this.rentForm.valueChanges.subscribe(() => {
      this.calculatePrice();
    });
  }

  calculatePrice() {
    const { startDate, endDate, pricingType } = this.rentForm.value;
    if (!startDate || !endDate || !pricingType) {
      this.rentalPrice.set(0);
      return;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    const diffTime = Math.abs(end.getTime() - start.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    const pricing = this.data.item.pricing?.find(p => p.pricingType === pricingType);
    if (!pricing) return;

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

    const command = new CreateRentalCommand({
      itemId: this.data.item.id!,
      startDate: formValue.startDate,
      endDate: formValue.endDate,
      pricingType: formValue.pricingType.toLowerCase()
    });

    this.rentalsClient.createRental(command).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] || 'rentals.error');
          this.isSubmitting.set(false);
        } else {
          this.toast.showSuccess('rentals.success');
          this.dialogRef.close(true);
          if (res.data?.orderId) {
            this.router.navigate(['/checkout', res.data.orderId, 'payment']);
          }
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
