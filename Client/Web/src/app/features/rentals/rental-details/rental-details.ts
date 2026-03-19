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
import { RentalsClient, RentalDetailDto, ReviewsClient } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

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
  public translate = inject(TranslateService);

  rentalId = signal('');
  isLoading = signal(true);
  isActionLoading = signal(false);
  rental = signal<RentalDetailDto | null>(null);
  
  isDamaged = signal(false); // For completion action

  // Review fields
  reviewRating = signal(5);
  reviewComment = signal('');
  
  userId = computed(() => this.auth.getUserData()?.id);
  
  isOwner = computed(() => {
    const r = this.rental();
    if (!r || !this.userId()) return false;
    return String((r as any).ownerId) === String(this.userId());
  });

  isAdmin = computed(() => this.auth.isAdmin());

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
    this.executeAction(() => (this.rentalsClient as any).completeRental(this.rentalId(), this.isDamaged()));
  }

  cancelRental() {
    this.executeAction(() => this.rentalsClient.cancelRental(this.rentalId()));
  }

  submitReview() {
    if (this.reviewRating() < 1) return;
    
    this.isActionLoading.set(true);
    this.reviewsClient.createReview(this.rentalId(), {
      rentalId: this.rentalId(),
      rating: this.reviewRating(),
      comment: this.reviewComment()
    } as any).subscribe({
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
      case 'pending': return 'warn';
      case 'confirmed': return 'accent';
      case 'active': return 'primary';
      case 'completed': return 'success';
      case 'cancelled':
      case 'rejected': return 'error';
      default: return 'default';
    }
  }
}
