import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { FormsModule } from '@angular/forms';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RentalsClient, RentalDetailDto, ReviewsClient, CreateReviewCommand, MediaClient, FileParameter, UploadRentalPhotosCommand, ChatClient, CreateChatCommand, RentalImageType } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
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
    MatDividerModule,
    MatProgressSpinnerModule,
    MatCheckboxModule,
    FormsModule,
    MatTooltipModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './rental-details.html',
  styleUrl: './rental-details.scss'
})
export class RentalDetailsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private rentalsClient = inject(RentalsClient);
  private reviewsClient = inject(ReviewsClient);
  private mediaClient = inject(MediaClient);
  private chatClient = inject(ChatClient);
  private auth = inject(AuthService);
  private toast = inject(ToastService);
  private permissionService = inject(PermissionService);

  isLoading = signal(true);
  isActionLoading = signal(false);
  rental = signal<RentalDetailDto | null>(null);

  isDamaged = signal(false);

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

  // Renter = logged-in user who is NOT the owner and NOT an admin
  isRenter = computed(() => !this.isOwner() && !this.isAdmin());

  isAdmin = computed(() => this.auth.isAdmin());

  canManage = computed(() => this.isAdmin());

  rentalId = computed(() => this.route.snapshot.paramMap.get('id') ?? '');

  ngOnInit() {
    this.loadRental();
  }

  loadRental() {
    this.isLoading.set(true);
    this.rentalsClient.getRentalById(this.rentalId()).subscribe({
      next: (res) => {
        if (res.data) this.rental.set(res.data);
        this.isLoading.set(false);
      },
      error: () => {
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'pending':   return 'status-pending';
      case 'confirmed': return 'status-confirmed';
      case 'active':    return 'status-active';
      case 'completed': return 'status-completed';
      case 'cancelled':
      case 'rejected':  return 'status-cancelled';
      case 'overdue':   return 'status-overdue';
      default:          return 'status-default';
    }
  }

  confirmRental() {
    this.isActionLoading.set(true);
    this.rentalsClient.confirmRental(this.rentalId()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(); this.isActionLoading.set(false); },
      error: () => { this.toast.showError('errors.generic'); this.isActionLoading.set(false); }
    });
  }

  cancelRental() {
    this.isActionLoading.set(true);
    this.rentalsClient.cancelRental(this.rentalId()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(); this.isActionLoading.set(false); },
      error: () => { this.toast.showError('errors.generic'); this.isActionLoading.set(false); }
    });
  }

  completeRental() {
    this.isActionLoading.set(true);
    this.rentalsClient.completeRental(this.rentalId(), this.isDamaged()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(); this.isActionLoading.set(false); },
      error: () => { this.toast.showError('errors.generic'); this.isActionLoading.set(false); }
    });
  }

  verifyHandoff() {
    if (!this.handoffCodeInput()) return;
    this.isActionLoading.set(true);
    this.rentalsClient.verifyHandoff(this.rentalId(), this.handoffCodeInput()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(); this.isActionLoading.set(false); },
      error: () => { this.toast.showError('errors.generic'); this.isActionLoading.set(false); }
    });
  }

  onPhotoSelected(event: Event, typeStr: 'Handover' | 'Return') {
    const input = event.target as HTMLInputElement;
    if (!input.files?.length) return;
    const file = input.files[0];
    const fileParam: FileParameter = { data: file, fileName: file.name };
    const type = typeStr === 'Handover' ? RentalImageType.Handover : RentalImageType.Return;
    
    this.isUploading.set(true);
    this.mediaClient.uploadMedia(this.rentalId(), 'Rental', fileParam).subscribe({
      next: (res) => {
        if (res.data?.id) {
          const cmd = new UploadRentalPhotosCommand({
            rentalId: this.rentalId(),
            imageIds: [res.data.id],
            type: type
          });
          this.rentalsClient.uploadRentalPhotos(this.rentalId(), cmd).subscribe({
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
      },
      error: () => {
        this.toast.showError('errors.uploadFailed');
        this.isUploading.set(false);
      }
    });
  }

  setRating(value: number) {
    this.reviewRating.set(value);
  }

  submitReview() {
    if (this.reviewRating() < 1) return;

    this.isActionLoading.set(true);
    this.reviewsClient.createReview(this.rentalId(), new CreateReviewCommand({
      rentalId: this.rentalId(),
      rating: this.reviewRating(),
      comment: this.reviewComment()
    })).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(); this.isActionLoading.set(false); },
      error: () => { this.toast.showError('errors.generic'); this.isActionLoading.set(false); }
    });
  }

  startChat() {
    const r = this.rental();
    if (!r) return;

    const targetUserId = r.ownerId;
    if (!targetUserId) return;

    const cmd = new CreateChatCommand({
      userId: targetUserId,
      itemId: r.itemId as any
    });

    this.isActionLoading.set(true);
    this.chatClient.createChat(cmd).subscribe({
      next: (res: any) => {
        const chatId = res?.data?.chatId || (res?.data as any)?.id;
        if (chatId) {
          this.router.navigate(['/chats', chatId]);
        }
        this.isActionLoading.set(false);
      },
      error: (err: any) => {
        console.error('Failed to start chat', err);
        this.toast.showError('errors.generic');
        this.isActionLoading.set(false);
      }
    });
  }
}
