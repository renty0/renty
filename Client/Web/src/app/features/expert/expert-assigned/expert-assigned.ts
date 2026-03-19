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
  assignments = signal<AssignedVerificationDto[]>([]);

  displayedColumns: string[] = ['item', 'checkType', 'dates', 'createdAt', 'actions'];

  ngOnInit() {
    this.loadAssignments();
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

  getLocalizedName(assignment: AssignedVerificationDto): string {
    return this.translate.currentLang === 'ar' ? (assignment.itemTitleAr || assignment.itemTitleEn || '') : (assignment.itemTitleEn || assignment.itemTitleAr || '');
  }
}
