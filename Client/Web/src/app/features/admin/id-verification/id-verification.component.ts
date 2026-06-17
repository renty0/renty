import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { finalize } from 'rxjs';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { IdentityClient, AdminIdVerificationDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { ReviewDialogComponent } from './review-dialog/review-dialog.component';

@Component({
  selector: 'app-id-verification',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatChipsModule,
    MatPaginatorModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatDialogModule,
    HeaderSectionComponent,
    TranslateModule
  ],
  templateUrl: './id-verification.component.html',
  styleUrl: './id-verification.component.scss'
})
export class IdVerificationComponent implements OnInit {
  private identityClient = inject(IdentityClient);
  private dialog = inject(MatDialog);
  private toast = inject(ToastService);

  verifications = signal<AdminIdVerificationDto[]>([]);
  totalCount = signal(0);
  pageSize = signal(10);
  pageIndex = signal(0);
  statusFilter = signal<string>('All');
  loading = signal(false);

  displayedColumns = [
    'user',
    'submittedAt',
    'status',
    'documents',
    'actions'
  ];

  ngOnInit(): void {
    this.loadVerifications();
  }

  loadVerifications() {
    this.loading.set(true);
    this.identityClient.getAdminIdVerifications(
      this.pageIndex() + 1,
      this.pageSize(),
      this.statusFilter()
    ).pipe(
      finalize(() => this.loading.set(false))
    ).subscribe({
      next: (res) => {
        if (!res.error && res.data) {
          this.verifications.set(res.data.verifications || []);
          this.totalCount.set(res.data.total || 0);
        } else {
          this.toast.showError(res.messages?.[0] || 'Failed to load verifications');
        }
      },
      error: (err: any) => {
        this.toast.showError('An error occurred while loading verifications');
      }
    });
  }

  setFilter(status: string) {
    if (this.statusFilter() === status) return;
    this.statusFilter.set(status);
    this.pageIndex.set(0); // Reset page on filter change
    this.loadVerifications();
  }

  onPageChange(event: PageEvent) {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
    this.loadVerifications();
  }

  openReviewDialog(request: AdminIdVerificationDto) {
    const dialogRef = this.dialog.open(ReviewDialogComponent, {
      width: '650px',
      data: { request }
    });

    dialogRef.afterClosed().subscribe(updated => {
      if (updated) {
        this.loadVerifications();
      }
    });
  }
}
