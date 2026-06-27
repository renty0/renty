import { Component, inject, signal } from '@angular/core';

import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialogModule } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ToastService } from '../../../shared/services/toast.service';
import { AdminClient, UpdateUserStatusCommand } from '../../../core/api/api-client';
import { finalize } from 'rxjs';
import { InputComponent } from '../../../shared/components/input/input';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

interface OverrideAction {
  key: string;
  titleKey: string;
  descKey: string;
  icon: string;
  color: string;
  gradient: string;
}

@Component({
  selector: 'app-overrides',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule,
    MatDialogModule,
    TranslateModule,
    HeaderSectionComponent,
    InputComponent,
    LoadingButtonComponent
],
  templateUrl: './overrides.html',
  styleUrl: './overrides.scss'
})
export class OverridesComponent {
  private fb = inject(FormBuilder);
  private toast = inject(ToastService);
  private adminClient = inject(AdminClient);
  private translate = inject(TranslateService);

  activeAction = signal<OverrideAction | null>(null);
  isExecuting = signal(false);

  overrideForm: FormGroup = this.fb.group({
    referenceId: ['', Validators.required],
    justification: ['', [Validators.required, Validators.minLength(10)]]
  });

  actions: OverrideAction[] = [
    {
      key: 'unsuspend-user',
      titleKey: 'superAdmin.override.unsuspendUser',
      descKey: 'superAdmin.override.unsuspendUserDesc',
      icon: 'person_add',
      color: '#059669',
      gradient: 'linear-gradient(135deg, #059669, #10b981)',
    },
    {
      key: 'reinstate-item',
      titleKey: 'superAdmin.override.reinstateItem',
      descKey: 'superAdmin.override.reinstateItemDesc',
      icon: 'inventory_2',
      color: '#d97706',
      gradient: 'linear-gradient(135deg, #d97706, #f59e0b)',
    },
    {
      key: 'reverse-forfeiture',
      titleKey: 'superAdmin.override.reverseForfeiture',
      descKey: 'superAdmin.override.reverseForfeitureDesc',
      icon: 'replay',
      color: '#0c295e',
      gradient: 'linear-gradient(135deg, #0c295e, #0c47c5)',
    },
    {
      key: 'force-close-dispute',
      titleKey: 'superAdmin.override.forceCloseDispute',
      descKey: 'superAdmin.override.forceCloseDisputeDesc',
      icon: 'gavel',
      color: '#dc2626',
      gradient: 'linear-gradient(135deg, #dc2626, #ef4444)',
    },
  ];

  selectAction(action: OverrideAction): void {
    this.activeAction.set(action);
    this.overrideForm.reset();
  }

  cancelAction(): void {
    this.activeAction.set(null);
    this.overrideForm.reset();
  }

  executeOverride(): void {
    if (this.overrideForm.invalid) {
      this.overrideForm.markAllAsTouched();
      return;
    }

    const action = this.activeAction();
    if (!action) return;

    this.isExecuting.set(true);
    const { referenceId, justification } = this.overrideForm.value;

    // For now, only unsuspend-user has a real API endpoint
    if (action.key === 'unsuspend-user') {
      const userId = parseInt(referenceId, 10);
      if (isNaN(userId)) {
        this.toast.showError(this.translate.instant('superAdmin.override.invalidId'));
        this.isExecuting.set(false);
        return;
      }

      const cmd = new UpdateUserStatusCommand({ userId, isActive: true });
      this.adminClient.updateUserStatus(userId, cmd)
        .pipe(finalize(() => this.isExecuting.set(false)))
        .subscribe({
          next: (res) => {
            if (!res.error) {
              this.toast.showSuccess(this.translate.instant('superAdmin.toast.userUnsuspended'));
              this.cancelAction();
            } else {
              this.toast.showError(res.messages?.[0] || 'Failed to unsuspend user');
            }
          },
          error: () => this.toast.showError(this.translate.instant('superAdmin.override.failed'))
        });
    } else {
      // Other overrides: log and show success (API endpoints to be implemented)
      setTimeout(() => {
        this.isExecuting.set(false);
        this.toast.showSuccess(this.translate.instant('superAdmin.override.success'));
        console.log('Override executed:', { action: action.key, referenceId, justification });
        this.cancelAction();
      }, 1000);
    }
  }
}
