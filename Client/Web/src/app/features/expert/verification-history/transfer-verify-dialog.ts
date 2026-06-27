import { Component, inject, signal } from '@angular/core';

import { FormsModule } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { RentalsClient } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
@Component({
  selector: 'app-transfer-verify-dialog',
  standalone: true,
  imports: [
    FormsModule,
    MatDialogModule,
    MatButtonModule,
    MatIconModule,
    TranslateModule,
    LoadingButtonComponent
],
  template: `
    <div class="dialog-container p-4" [dir]="translate.currentLang === 'ar' ? 'rtl' : 'ltr'">
      <h2 mat-dialog-title class="m-0 mb-3 flex align-items-center gap-2 text-primary font-bold">
        <mat-icon>handshake</mat-icon>
        {{ getTitle() | translate }}
      </h2>
      <mat-dialog-content class="mat-typography pb-4">
        <p class="text-600 mb-4 text-sm">
          {{ getDescription() | translate }}
        </p>
        
        <div class="code-input-row flex gap-2">
          <input [(ngModel)]="code" [placeholder]="'expert.history.dialog.placeholder' | translate"
            class="custom-input flex-1 p-3 border-round border-1 border-200 text-center font-bold text-xl outline-none w-full">
        </div>
      </mat-dialog-content>
      
      <mat-dialog-actions align="end" class="pt-3 border-top-1 border-100">
        <button mat-button mat-dialog-close color="warn">{{ 'expert.history.dialog.cancel' | translate }}</button>
        <app-loading-button color="primary" [loading]="isLoading()" (clicked)="verify()" [disabled]="!code()">
          {{ getButtonLabel() | translate }}
        </app-loading-button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .dialog-container { background: white; border-radius: 12px; }
    .custom-input:focus { border-color: var(--primary-color) !important; box-shadow: 0 0 0 2px var(--primary-50) !important; }
  `]
})
export class TransferVerifyDialogComponent {
  dialogRef = inject(MatDialogRef<TransferVerifyDialogComponent>);
  data = inject<{ rentalId: string, type: string }>(MAT_DIALOG_DATA);
  rentalsClient = inject(RentalsClient);
  toast = inject(ToastService);
  translate = inject(TranslateService);
  
  code = signal('');
  isLoading = signal(false);

  getTitle(): string {
    switch(this.data.type) {
      case 'ReceiveFromOwner': return 'expert.history.dialog.ReceiveFromOwner.title';
      case 'DeliveryToRenter': return 'expert.history.dialog.DeliveryToRenter.title';
      case 'ReceiveFromRenter': return 'expert.history.dialog.ReceiveFromRenter.title';
      case 'DeliveryToOwner': return 'expert.history.dialog.DeliveryToOwner.title';
      default: return 'expert.history.dialog.title';
    }
  }

  getDescription(): string {
    switch(this.data.type) {
      case 'ReceiveFromOwner': return 'expert.history.dialog.ReceiveFromOwner.desc';
      case 'DeliveryToRenter': return 'expert.history.dialog.DeliveryToRenter.desc';
      case 'ReceiveFromRenter': return 'expert.history.dialog.ReceiveFromRenter.desc';
      case 'DeliveryToOwner': return 'expert.history.dialog.DeliveryToOwner.desc';
      default: return 'expert.history.dialog.description';
    }
  }

  getButtonLabel(): string {
    switch(this.data.type) {
      case 'ReceiveFromOwner': return 'expert.history.dialog.ReceiveFromOwner.btn';
      case 'DeliveryToRenter': return 'expert.history.dialog.DeliveryToRenter.btn';
      case 'ReceiveFromRenter': return 'expert.history.dialog.ReceiveFromRenter.btn';
      case 'DeliveryToOwner': return 'expert.history.dialog.DeliveryToOwner.btn';
      default: return 'expert.history.dialog.verify_btn';
    }
  }

  verify() {
    if (!this.code()) return;
    this.isLoading.set(true);
    
    this.rentalsClient.verifyTransfer(this.data.rentalId, this.code()).subscribe({
      next: () => {
        this.toast.showSuccess(this.translate.instant('expert.history.dialog.success'));
        this.dialogRef.close(true);
      },
      error: (err: any) => {
        let msg = 'Invalid code or an error occurred';
        if (err.messages && err.messages.length > 0) {
          msg = err.messages[0];
        } else if (err.response) {
            try {
               const parsed = JSON.parse(err.response);
               if (parsed.messages && parsed.messages.length > 0) msg = parsed.messages[0];
            } catch(e) {}
        }
        this.toast.showError(msg);
        this.isLoading.set(false);
      }
    });
  }
}
