import { Component, Inject, ViewEncapsulation } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef, MatDialogContent, MatDialogActions, MatDialogTitle } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { FormsModule } from '@angular/forms';
import { animate, style, transition, trigger } from '@angular/animations';
import { LoadingButtonComponent } from '../loading-button/loading-button.component';

export interface ConfirmDialogData {
  title?: string;
  message: string;
  detailsHtml?: string; 
  confirmText?: string;
  cancelText?: string;
  color?: 'primary' | 'accent' | 'warn';
  showInput?: boolean;
  inputLabel?: string;
  inputPlaceholder?: string;
  inputValue?: string;
  inputRequired?: boolean;
  warningMessage?: string;
  showRefundInput?: boolean;
  maxRefundAmount?: number;
  refundAmountValue?: number;
  loading?: boolean;
}

@Component({
  selector: 'app-confirm-dialog',
  templateUrl: './confirm-dialog.component.html',
  imports: [
    MatDialogContent,
    MatDialogActions,
    MatDialogTitle,
    MatFormFieldModule,
    MatInputModule,
    MatIconModule,
    FormsModule,
    LoadingButtonComponent
  ],
  animations: [
    trigger('appear', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('150ms ease-in', style({ opacity: 1 })),
      ]),
    ]),
  ],
  styleUrl: './confirm-dialog.component.scss',
  encapsulation: ViewEncapsulation.None,
})
export class ConfirmDialogComponent {
  inputValue: string = '';
  refundAmount: number = 0;

  constructor(
    public dialogRef: MatDialogRef<ConfirmDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: ConfirmDialogData
  ) {
    if (!this.data.color) {
      this.data.color = 'primary';
    }
    if (this.data.inputValue) {
      this.inputValue = this.data.inputValue;
    }
    if (this.data.refundAmountValue !== undefined) {
      this.refundAmount = this.data.refundAmountValue;
    } else if (this.data.maxRefundAmount !== undefined) {
      this.refundAmount = this.data.maxRefundAmount;
    }
  }

  onConfirm() {
    if (this.data.showInput && this.data.showRefundInput) {
      this.dialogRef.close({
        confirmed: true,
        inputValue: this.inputValue,
        refundAmount: this.refundAmount
      });
    } else if (this.data.showInput) {
      this.dialogRef.close({ confirmed: true, inputValue: this.inputValue });
    } else if (this.data.showRefundInput) {
      this.dialogRef.close({
        confirmed: true,
        refundAmount: this.refundAmount
      });
    } else {
      this.dialogRef.close(true);
    }
  }

  onCancel() {
    this.dialogRef.close(false);
  }

  get isRefundAmountValid(): boolean {
    if (!this.data.showRefundInput || this.data.maxRefundAmount === undefined) {
      return true;
    }
    return this.refundAmount >= 0 && this.refundAmount <= this.data.maxRefundAmount;
  }

  get isInputValid(): boolean {
    if (!this.data.showInput || !this.data.inputRequired) {
      return true;
    }
    return this.inputValue.trim().length > 0;
  }

  get canConfirm(): boolean {
    return this.isRefundAmountValid && this.isInputValid;
  }
}
