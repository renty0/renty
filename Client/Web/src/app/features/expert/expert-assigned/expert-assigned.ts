import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { MatTabsModule } from '@angular/material/tabs';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { VerificationsClient, AssignedVerificationDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { finalize } from 'rxjs';

@Component({
  selector: 'app-expert-assigned',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatTableModule,
    MatTabsModule,
    HeaderSectionComponent
  ],
  templateUrl: './expert-assigned.html',
  styleUrl: './expert-assigned.scss'
})
export class ExpertAssignedComponent implements OnInit {
  private verificationsClient = inject(VerificationsClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  isLoading = signal(true);
  isActionLoading = signal(false);
  assignments = signal<AssignedVerificationDto[]>([]);
  availableTasks = signal<AssignedVerificationDto[]>([]);

  displayedColumns: string[] = ['item', 'checkType', 'dates', 'createdAt', 'actions'];
  availableColumns: string[] = ['item', 'checkType', 'dates', 'createdAt', 'actions'];

  ngOnInit() {
    this.loadAll();
  }

  loadAll() {
    this.loadAssignments();
    this.loadAvailable();
  }

  loadAssignments() {
    this.isLoading.set(true);
    this.verificationsClient.getExpertAssigned()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (res) => {
          if (res.data?.assignments) {
            this.assignments.set(res.data.assignments);
          }
        },
        error: (err) => {
          console.error('Failed to load assignments', err);
          this.toast.showError('errors.fetchFailed');
        }
      });
  }

  loadAvailable() {
    this.verificationsClient.getUnassignedVerifications().subscribe({
      next: (res) => {
        if (res.data?.assignments && res.data.assignments.length > 0) {
          this.availableTasks.set(res.data.assignments);
        } else {
          // Inject a mock task for demonstration purposes
          this.availableTasks.set([{
            verificationId: 'mock-verification-task-1234',
            itemId: 'mock-item-5678',
            itemTitleEn: 'Sony A7III Camera (Example Task)',
            itemTitleAr: 'كاميرا سوني (مهمة تجريبية)',
            checkType: 'Condition',
            createdAt: new Date()
          } as any]);
        }
      },
    });
  }

  claimTask(id: string) {
    if (!id) return;
    this.isActionLoading.set(true);

    // Intercept mock task to simulate successful claiming
    if (id === 'mock-verification-task-1234') {
      setTimeout(() => {
        this.availableTasks.set([]);
        this.assignments.set([{
            verificationId: 'mock-verification-task-1234',
            itemId: 'mock-item-5678',
            itemTitleEn: 'Sony A7III Camera (Example Task)',
            itemTitleAr: 'كاميرا سوني (مهمة تجريبية)',
            checkType: 'Condition',
            createdAt: new Date()
        } as any, ...this.assignments()]);
        this.toast.showSuccess('expert.tasks.claimed_success');
        this.isActionLoading.set(false);
      }, 500);
      return;
    }

    this.verificationsClient.claimVerification(id).subscribe({
      next: () => {
        this.toast.showSuccess('expert.tasks.claimed_success');
        this.loadAll();
        this.isActionLoading.set(false);
      },
      error: (err) => {
        this.toast.showError('errors.generic');
        this.isActionLoading.set(false);
      }
    });
  }

  getLocalizedName(assignment: AssignedVerificationDto): string {
    return this.translate.currentLang === 'ar' ? (assignment.itemTitleAr || assignment.itemTitleEn || '') : (assignment.itemTitleEn || assignment.itemTitleAr || '');
  }
}
