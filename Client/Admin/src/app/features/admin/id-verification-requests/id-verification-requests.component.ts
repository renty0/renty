import { Component, inject, OnInit, signal, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSelectModule } from '@angular/material/select';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { IdentityClient, IdVerificationRequestDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { finalize } from 'rxjs';
import { ReviewIdDialogComponent } from './review-id-dialog/review-id-dialog.component';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';

@Component({
  selector: 'app-id-verification-requests',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatPaginatorModule,
    MatTooltipModule,
    MatDialogModule,
    MatSelectModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './id-verification-requests.component.html',
  styleUrl: './id-verification-requests.component.scss'
})
export class IdVerificationRequestsComponent implements OnInit {
  private identityClient = inject(IdentityClient);
  private toastService = inject(ToastService);
  private dialog = inject(MatDialog);
  public translate = inject(TranslateService);
  private signalrService = inject(NotificationSignalrService);

  requests = signal<IdVerificationRequestDto[]>([]);
  isLoading = signal<boolean>(true);
  error = signal<string | null>(null);

  // Pagination & Sorting
  totalRequests = signal<number>(0);
  pageSize = signal<number>(10);
  pageIndex = signal<number>(0);
  sortOrder = signal<string>('desc');

  displayedColumns: string[] = ['user', 'email', 'date', 'status', 'actions'];

  constructor() {
    effect(() => {
      const trigger = this.signalrService.idVerificationRequestTrigger();
      if (trigger > 0) {
        untracked(() => {
          this.loadRequests();
          this.toastService.showSuccess('idVerification.newRequestReceived');
        });
      }
    });
  }

  ngOnInit() {
    this.loadRequests();
  }

  loadRequests() {
    this.isLoading.set(true);
    this.error.set(null);

    // Fetch pending requests specifically
    this.identityClient.getIdVerificationRequests(this.pageIndex() + 1, this.pageSize(), 'Pending', this.sortOrder())
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (res) => {
          if (res.data) {
            this.requests.set(res.data.requests || []);
            this.totalRequests.set(res.data.total || 0);
          }
        },
        error: (err) => {
          console.error('Error loading ID verification requests', err);
          this.error.set('idVerification.loadFailed');
          this.toastService.showError('idVerification.loadFailed');
        }
      });
  }

  onPageChange(event: PageEvent) {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
    this.loadRequests();
  }

  onSortChange(value: string) {
    this.sortOrder.set(value);
    this.pageIndex.set(0);
    this.loadRequests();
  }

  reviewRequest(request: IdVerificationRequestDto) {
    const dialogRef = this.dialog.open(ReviewIdDialogComponent, {
      width: '800px',
      maxWidth: '90vw',
      maxHeight: '90vh',
      data: { request }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        // Reload list if a decision was made
        this.loadRequests();
      }
    });
  }

  getStatusClass(status: string | undefined): string {
    if (!status) return '';
    switch (status.toLowerCase()) {
      case 'pending': return 'status-pending';
      case 'approved': return 'status-approved';
      case 'rejected': return 'status-rejected';
      default: return '';
    }
  }

  getInitials(request: IdVerificationRequestDto): string {
    return (request.firstName?.[0] || '') + (request.lastName?.[0] || '');
  }
}
