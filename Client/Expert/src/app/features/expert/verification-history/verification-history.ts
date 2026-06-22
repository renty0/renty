import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDividerModule } from '@angular/material/divider';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { InputComponent, SelectOption } from '../../../shared/components/input/input';
import { VerificationsClient, VerificationDto, CreateVerificationCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { TransferVerifyDialogComponent } from './transfer-verify-dialog';

export interface IPersonInfoDto {
  fullName: string;
  phone?: string;
  profilePicture?: string;
}

export interface IRentalInfoDto {
  rentalId: string;
  startDate: string;
  endDate: string;
  rentalPrice: number;
  depositAmount: number;
  status: string;
  renter: IPersonInfoDto;
  currentPossession: string;
  hasReturnTransfers: boolean;
  pendingTransferType?: string;
}

export interface IItemVerificationDetailsDto {
  itemId: string;
  titleAr: string;
  titleEn: string;
  imageUrl?: string;
  condition?: string;
  city?: string;
  owner: IPersonInfoDto;
  activeRental?: IRentalInfoDto;
}
@Component({
  selector: 'app-verification-history',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatDividerModule,
    HeaderSectionComponent,
    LoadingButtonComponent,
    InputComponent,
    MatDialogModule
  ],
  templateUrl: './verification-history.html',
  styleUrl: './verification-history.scss'
})
export class VerificationHistoryComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private fb = inject(FormBuilder);
  private verificationsClient = inject(VerificationsClient);
  private toast = inject(ToastService);
  private dialog = inject(MatDialog);
  public translate = inject(TranslateService);

  itemId = signal('');
  verificationId = signal<string | null>(null);
  isLoading = signal(true);
  isSubmitting = signal(false);
  itemDetails = signal<IItemVerificationDetailsDto | null>(null);
  verifications = signal<VerificationDto[]>([]);
  pendingVerification = signal<any>(null);

  verifyForm = this.fb.group({
    status: ['', Validators.required],
    checkType: ['', Validators.required],
    notes: [''],
    deductionAmount: [null],
    newDepositAmount: [null]
  });

  checkTypeOptions: SelectOption[] = [
    { name: 'expert.checkTypes.beforeRent', code: 'before_rent' },
    { name: 'expert.checkTypes.afterReturn', code: 'after_return' }
  ];

  statusOptions: SelectOption[] = [
    { name: 'expert.status.approved', code: 'approved' },
    { name: 'expert.status.rejected', code: 'rejected' }
  ];

  destinationOptions: SelectOption[] = [
    { name: 'labels.renter', code: 'renter' },
    { name: 'labels.owner', code: 'owner' }
  ];

  ngOnInit() {
    this.itemId.set(this.route.snapshot.paramMap.get('id') || '');
    if (this.itemId()) {
      this.loadHistory();
    }
  }

  loadHistory() {
    this.isLoading.set(true);
    this.verificationsClient.getVerifications(this.itemId()).subscribe({
      next: (res) => {
        if (res.data) {
          const dataAny = res.data as any;
          if (dataAny.itemDetails) {
            this.itemDetails.set(dataAny.itemDetails);
          }
          if (dataAny.verifications) {
            this.verifications.set(dataAny.verifications);
            const pending = dataAny.verifications.find((v: any) => v.status?.toLowerCase() === 'pending');
            if (pending) {
              this.pendingVerification.set(pending);
            } else {
              this.pendingVerification.set(null);
            }
            if (pending && pending.checkType) {
              const apiType = pending.checkType;
              const formType = apiType.includes('BeforeRent') ? 'before_rent' : 'after_return';
              this.verifyForm.patchValue({ checkType: formType });
            }
            
            // Always keep the form enabled — canSubmitForm() gates the submit button only
            this.verifyForm.enable();
          }
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  canSubmitForm(): boolean {
    const formType = this.verifyForm.get('checkType')?.value;
    const rental = this.itemDetails()?.activeRental;

    if (formType === 'after_return') {
      // after_return requires an active rental that has return transfers and expert has possession
      if (!rental) return false;
      if (rental.currentPossession !== 'Expert') return false;
      if (!rental.hasReturnTransfers) return false;
      return true;
    }

    // before_rent: allowed even without active rental
    // but if there IS an active rental, expert must have possession
    if (rental && rental.currentPossession !== 'Expert') return false;

    return true;
  }

  onSubmit() {
    if (this.verifyForm.invalid) return;

    this.isSubmitting.set(true);
    const formVal = this.verifyForm.value;

    const cmd = new CreateVerificationCommand({
      itemId: this.itemId(),
      rentalId: this.itemDetails()?.activeRental?.rentalId || undefined,
      checkType: formVal.checkType!,
      status: formVal.status!,
      notes: formVal.notes || '',
      deductionAmount: formVal.deductionAmount || undefined,
      newDepositAmount: formVal.newDepositAmount || undefined
    });

    this.verificationsClient.createVerification(this.itemId(), cmd).subscribe({
      next: (res) => {
        if (!res.error) {
          this.toast.showSuccess('expert.verifySuccess');
          this.loadHistory();
          this.verifyForm.reset({ checkType: formVal.checkType });
        } else {
          this.toast.showError(res.messages?.[0] || 'errors.unknownError');
        }
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.toast.showError('errors.unknownError');
        this.isSubmitting.set(false);
      }
    });
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'approved': return 'success';
      case 'rejected': return 'error';
      case 'pending': return 'warn';
      default: return 'default';
    }
  }

  openTransferVerify(type: string) {
    const activeRental = this.itemDetails()?.activeRental;
    if (!activeRental) return;
    const dialogRef = this.dialog.open(TransferVerifyDialogComponent, {
      width: '400px',
      data: { rentalId: activeRental.rentalId, type: type }
    });
    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loadHistory();
      }
    });
  }
}
