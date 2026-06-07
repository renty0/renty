import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatRadioModule } from '@angular/material/radio';
import { FormsModule } from '@angular/forms';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RentalsClient, RentalDetailDto, ReviewsClient, CreateReviewCommand, MediaClient, FileParameter, UploadRentalPhotosBody, ChatClient, CreateChatCommand, RentalImageType } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { DisputeModalComponent } from '../dispute-modal/dispute-modal';

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
    MatRadioModule,
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
  private dialog = inject(MatDialog);
  private http = inject(HttpClient);

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

  otherUserName = computed(() => {
    const r = this.rental();
    if (!r) return '';
    return this.isOwner() ? r.renterFirstName : r.ownerFirstName;
  });

  otherUserId = computed(() => {
    const r = this.rental();
    if (!r) return null;
    return this.isOwner() ? r.renterId : r.ownerId;
  });

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

  isUnderReview = computed(() => {
    const r = this.rental();
    if (!r) return false;
    // Consider under review if expert requested but not yet assigned
    return !!(r.renterWantsExpertReview || r.ownerWantsExpertReview) && !r.assignedExpertId;
  });

  // Determine who currently has the product
  productHolder = computed(() => {
    const r = this.rental();
    if (!r) return 'unknown';

    const status = r.status?.toLowerCase();
    if (status === 'pending' || status === 'confirmed') {
      return 'owner';
    } else if (status === 'active' || status === 'overdue') {
      // If expert is assigned and verification is pending, expert has it
      if (r.assignedExpertId && !r.verifications?.[0]?.status) {
        return 'expert';
      }
      // Otherwise renter has it
      return 'renter';
    } else if (status === 'completed' || status === 'cancelled' || status === 'rejected') {
      return 'owner';
    }
    return 'unknown';
  });

  // Check if return action is needed based on who has the product
  needsReturnAction = computed(() => {
    const holder = this.productHolder();
    const r = this.rental();
    if (!r) return false;

    const status = r.status?.toLowerCase();
    if (status !== 'active' && status !== 'overdue') return false;

    // If owner is viewing and product is with renter or expert, owner needs to wait for return
    if (this.isOwner() && (holder === 'renter' || holder === 'expert')) {
      return true;
    }
    // If renter is viewing and product is with renter, renter needs to return
    if (this.isRenter() && holder === 'renter') {
      return true;
    }
    // If expert is viewing and product is with expert, expert needs to return
    if (this.isAdmin() && holder === 'expert') {
      return true;
    }

    return false;
  });

  returnDeliveryMethod = signal<'ByHand' | 'NearestLocation' | 'DeliveryService'>('ByHand');
  showReturnOptions = signal(false);

  initiateReturn() {
    this.showReturnOptions.set(true);
  }

  updatePossession(action: string, method: string) {
    this.isActionLoading.set(true);
    const url = `/api/v1/rentals/${this.rentalId()}/possession?action=${action}&method=${method}`;
    this.http.put(url, {}).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental();
        this.isActionLoading.set(false);
        this.showReturnOptions.set(false);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.isActionLoading.set(false);
      }
    });
  }

  confirmReceipt() {
    this.updatePossession('confirm_receipt', 'ByHand');
  }

  confirmReturn() {
    this.isActionLoading.set(true);
    const method = this.returnDeliveryMethod();

    if (this.isRenter()) {
      const url = `/api/v1/rentals/${this.rentalId()}/possession?action=initiate_return&method=${method}`;
      this.http.put(url, {}).subscribe({
        next: () => {
          if (method === 'DeliveryService') {
            this.toast.showSuccess('rentals.delivery.initiated');
            this.simulateReturnDelivery();
          } else if (method === 'NearestLocation') {
            this.toast.showSuccess('rentals.nearest_location.confirmed');
          } else {
            this.toast.showSuccess('rentals.return.confirmed');
          }
          this.loadRental();
          this.showReturnOptions.set(false);
          this.isActionLoading.set(false);
        },
        error: () => {
          this.toast.showError('errors.generic');
          this.isActionLoading.set(false);
        }
      });
    } else {
      this.rentalsClient.completeRental(this.rentalId(), this.isDamaged()).subscribe({
        next: () => {
          this.toast.showSuccess('rentals.return.confirmed');
          this.loadRental();
          this.showReturnOptions.set(false);
          this.isActionLoading.set(false);
        },
        error: () => {
          this.toast.showError('errors.generic');
          this.isActionLoading.set(false);
        }
      });
    }
  }

  simulateReturnDelivery() {
    setTimeout(() => {
      this.toast.showInfo('rentals.delivery.picked_up');
    }, 2000);

    setTimeout(() => {
      this.toast.showInfo('rentals.delivery.in_transit');
    }, 4000);

    setTimeout(() => {
      this.toast.showSuccess('rentals.delivery.delivered');
      const url = `/api/v1/rentals/${this.rentalId()}/possession?action=confirm_receipt&method=ByHand`;
      this.http.put(url, {}).subscribe({
        next: () => this.loadRental()
      });
    }, 6000);
  }

  cancelReturnOptions() {
    this.showReturnOptions.set(false);
  }

  requestExpertReview() {
    this.isActionLoading.set(true);
    this.rentalsClient.requestExpertReview(this.rentalId()).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental();
        this.isActionLoading.set(false);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.isActionLoading.set(false);
      }
    });
  }

  cancelExpertReview() {
    this.isActionLoading.set(true);
    this.rentalsClient.cancelExpertReview(this.rentalId()).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental();
        this.isActionLoading.set(false);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.isActionLoading.set(false);
      }
    });
  }

  chooseDelivery() {
    this.updatePossession('send_to_expert', 'DeliveryService');
    this.simulateDelivery();
  }

  chooseNearestLocation() {
    this.updatePossession('send_to_expert', 'NearestLocation');
  }

  simulateDelivery() {
    setTimeout(() => {
      this.toast.showInfo('rentals.delivery.picked_up');
    }, 2000);

    setTimeout(() => {
      this.toast.showInfo('rentals.delivery.in_transit');
    }, 4000);

    setTimeout(() => {
      this.toast.showSuccess('rentals.delivery.delivered');
      const url = `/api/v1/rentals/${this.rentalId()}/possession?action=confirm_receipt&method=ByHand`;
      this.http.put(url, {}).subscribe({
        next: () => this.loadRental()
      });
    }, 6000);
  }

  submitExpertReview() {
    const r = this.rental();
    if (r && r.itemId) {
      this.router.navigate(['/expert/verify', r.itemId]);
    }
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
          const cmd = new UploadRentalPhotosBody({
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

    const targetUserId = this.otherUserId();
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

  openDispute() {
    const dialogRef = this.dialog.open(DisputeModalComponent, {
      width: '500px',
      data: { rentalId: this.rentalId() },
      panelClass: 'glass-dialog'
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        // If dispute was opened, reload the rental to update status
        this.loadRental();
      }
    });
  }
}
