import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { FormsModule } from '@angular/forms';
import { RentalsClient, RentalDetailDto, ReviewsClient, CreateReviewCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { PermissionService } from '../../../core/services/permission.service';
import { PermissionType } from '../../../core/constants/permissions';

@Component({
  selector: 'app-rental-details',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatDividerModule,
    MatProgressSpinnerModule,
    MatCheckboxModule,
    FormsModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './rental-details.html',
  styleUrl: './rental-details.scss'
})
export class RentalDetailsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private rentalsClient = inject(RentalsClient);
  private reviewsClient = inject(ReviewsClient);
  private toast = inject(ToastService);
  private auth = inject(AuthService);
  private http = inject(HttpClient);
  public translate = inject(TranslateService);
  private permissionService = inject(PermissionService);
  private baseUrl = environment.apiUrl;

  rentalId = signal('');
  isLoading = signal(true);
  isActionLoading = signal(false);
  rental = signal<RentalDetailDto | null>(null);
  
  isDamaged = signal(false); // For completion action

  // Review fields
  reviewRating = signal(5);
  reviewComment = signal('');
  
  handoffCodeInput = signal('');
  isUploading = signal(false);
  
  userId = computed(() => this.auth.getUserData()?.id);
  
  isOwner = computed(() => {
    const r = this.rental();
    if (!r || !this.userId()) return false;
    return String(r.ownerId) === String(this.userId());
  });

  canManage = computed(() => this.permissionService.hasPermission(PermissionType.Rentals_Edit));

  ngOnInit() {
    this.rentalId.set(this.route.snapshot.paramMap.get('id') || '');
    if (this.rentalId()) {
      this.loadRental();
    }
  }

  loadRental() {
    this.isLoading.set(true);
    this.rentalsClient.getRentalById(this.rentalId()).subscribe({
      next: (res) => {
        if (res.data) {
          this.rental.set(res.data);
        } else {
          this.toast.showError('errors.fetchFailed');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load rental', err);
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  confirmRental() {
    this.executeAction(() => this.rentalsClient.confirmRental(this.rentalId()));
  }

  completeRental() {
    this.executeAction(() => this.rentalsClient.completeRental(this.rentalId(), this.isDamaged()));
  }

  cancelRental() {
    this.executeAction(() => this.rentalsClient.cancelRental(this.rentalId()));
  }

  verifyHandoff() {
    if (!this.handoffCodeInput()) return;
    this.isActionLoading.set(true);
    this.http.post(`${this.baseUrl}/api/v1/rentals/${this.rentalId()}/verify-handoff`, {
      rentalId: this.rentalId(),
      code: this.handoffCodeInput()
    }).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental();
        this.isActionLoading.set(false);
      },
      error: (err) => {
        this.toast.showError(err.error?.message || 'rentals.error');
        this.isActionLoading.set(false);
      }
    });
  }

  onPhotoSelected(event: any, type: string) {
    const file = event.target.files[0];
    if (!file) return;

    this.isUploading.set(true);
    const formData = new FormData();
    formData.append('File', file);
    formData.append('Type', type);

    this.http.post(`${this.baseUrl}/api/v1/rentals/${this.rentalId()}/photos`, formData).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental();
        this.isUploading.set(false);
      },
      error: () => {
        this.toast.showError('errors.uploadFailed');
        this.isUploading.set(false);
      }
    });
  }

  submitReview() {
    if (this.reviewRating() < 1) return;
    
    this.isActionLoading.set(true);
    this.reviewsClient.createReview(this.rentalId(), new CreateReviewCommand({
      rentalId: this.rentalId(),
      rating: this.reviewRating(),
      comment: this.reviewComment()
    })).subscribe({
      next: () => {
        this.toast.showSuccess('rentals.actions.review_success');
        this.loadRental();
        this.isActionLoading.set(false);
      },
      error: () => {
        this.toast.showError('rentals.actions.review_error');
        this.isActionLoading.set(false);
      }
    });
  }

  setRating(rating: number) {
    this.reviewRating.set(rating);
  }

  private executeAction(action: () => any) {
    this.isActionLoading.set(true);
    action().subscribe({
      next: (res: any) => {
        if (!res.error) {
          this.toast.showSuccess('rentals.actions.success');
          this.loadRental();
        } else {
          this.toast.showError(res.messages?.[0] || 'rentals.error');
        }
        this.isActionLoading.set(false);
      },
      error: () => {
        this.toast.showError('rentals.error');
        this.isActionLoading.set(false);
      }
    });
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'pending': return 'bg-yellow-50 text-yellow-700 border-1 border-yellow-100';
      case 'confirmed': return 'bg-indigo-50 text-indigo-700 border-1 border-indigo-100';
      case 'active': return 'bg-primary-50 text-primary-700 border-1 border-primary-100';
      case 'completed': return 'bg-green-50 text-green-700 border-1 border-green-100';
      case 'cancelled':
      case 'rejected': return 'bg-red-50 text-red-700 border-1 border-red-100';
      default: return 'bg-gray-50 text-gray-700 border-1 border-gray-100';
    }
  }
}
