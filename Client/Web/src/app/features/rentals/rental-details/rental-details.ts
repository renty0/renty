import { Component, inject, OnInit, OnDestroy, signal, computed, effect, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { forkJoin } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatRadioModule } from '@angular/material/radio';
import { FormsModule } from '@angular/forms';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RentalsClient, RentalDetailDto, ReviewsClient, CreateReviewCommand, MediaClient, FileParameter, UploadRentalPhotosBody, ChatClient, CreateChatCommand, RentalImageType, SetHandoffMethodBody } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { DisputeModalComponent } from '../dispute-modal/dispute-modal';
import { environment } from '../../../../environments/environment';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';

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
export class RentalDetailsComponent implements OnInit, OnDestroy {
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
  private translate = inject(TranslateService);
  private signalrService = inject(NotificationSignalrService);

  private signalrReloadTimeout: any = null;

  constructor() {
    effect(() => {
      const newNotif = this.signalrService.newNotification();
      if (newNotif) {
        untracked(() => {
          if (newNotif.actionUrl && this.router.url.includes(newNotif.actionUrl) && newNotif.type === 'transfer') {
            // Debounce: multiple notifications can arrive in quick succession
            clearTimeout(this.signalrReloadTimeout);
            this.signalrReloadTimeout = setTimeout(() => this.loadRental(true), 1000);
          }
        });
      }
    });
  }

  ngOnDestroy() {
    clearTimeout(this.signalrReloadTimeout);
  }

  isLoading = signal(true);
  loadingAction = signal<string | null>(null);
  rental = signal<(RentalDetailDto & { hasReview?: boolean }) | null>(null);

  isDamaged = signal(false);

  reviewRating = signal(5);
  reviewComment = signal('');

  transferCodeInput = signal('');
  isUploading = signal(false);

  selectedDeliveryMethodFromExpert = signal<string>('ByHand');
  submittingDeliveryFromExpert = signal(false);
  selectedImage = signal<string | null>(null);

  userId = computed(() => this.auth.getUserData()?.id);

  isOwner = computed(() => {
    const r = this.rental();
    if (!r || !this.userId()) return false;
    return String(r.ownerId) === String(this.userId());
  });

  // Renter = logged-in user who is NOT the owner and NOT an admin
  isRenter = computed(() => !this.isOwner() && !this.isAdmin());

  isAdmin = computed(() => this.auth.isAdmin());
  
  hasBeforeRentApproval = computed(() => {
    const r = this.rental();
    if (!r || !r.verifications) return false;
    const v = r.verifications.find(x => x.checkType?.toLowerCase().includes('before'));
    return v?.status?.toLowerCase() === 'approved';
  });
  relevantVerifications = computed(() => {
    const r = this.rental();
    if (!r) return [];
    
    if (!r.verifications || r.verifications.length === 0) {
      if (r.renterWantsExpertReview || r.ownerWantsExpertReview) return [null];
      return [];
    }

    const beforeRent = r.verifications.find(v => v.checkType?.toLowerCase() === 'beforerent' || v.checkType?.toLowerCase() === 'before_rent');
    const afterReturn = r.verifications.find(v => v.checkType?.toLowerCase() === 'afterreturn' || v.checkType?.toLowerCase() === 'after_return');
    
    const results = [];
    if (beforeRent) results.push(beforeRent);
    else if (!beforeRent && !afterReturn) results.push(null);
    
    const status = r.status?.toLowerCase();
    const showAfterReturn = status === 'active' || status === 'completed' || status === 'overdue' || status === 'disputed';
    
    if (showAfterReturn && afterReturn) {
      results.push(afterReturn);
    }
    
    return results;
  });

  hasAvailableActions = computed(() => {
    const r = this.rental();
    if (!r) return false;
    const s = r.status?.toLowerCase();
    
    if (this.isRenter()) {
      if (s === 'pending') return true;
      if (s === 'active' || s === 'overdue') return true;
    }
    
    if (this.isOwner()) {
      if (s === 'pending' || s === 'confirmed') return true;
      if ((r.renterWantsExpertReview || r.ownerWantsExpertReview) && r.currentPossession?.toString() === 'Owner') return true;
      if (s === 'active' || s === 'overdue') return true;
      if (!r.ownerWantsExpertReview && !r.renterWantsExpertReview && s !== 'completed' && s !== 'cancelled') return true;
    }
    
    if (this.isAdmin()) {
      if (s === 'pending') return true;
      if (s !== 'completed' && s !== 'cancelled' && s !== 'rejected') return true;
    }
    
    if ((this.isRenter() || this.isOwner()) && (s === 'active' || s === 'completed' || s === 'overdue' || s === 'disputed' || s === 'confirmed' || s === 'awaitingpickup')) {
      return true;
    }
    
    return false;
  });


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

  isExpertReviewRequired = computed(() => {
    const r = this.rental();
    if (!r) return false;
    return r.ownerWantsExpertReview || r.renterWantsExpertReview;
  });

  isBeforeRentApproved = computed(() => {
    const r = this.rental();
    if (!r) return false;
    if (!this.isExpertReviewRequired()) return true;
    return r.verifications?.some(v => v.checkType === 'BeforeRent' && v.status === 'Approved') ?? false;
  });

  activeTransfer = computed(() => {
    const r = this.rental();
    if (!r || !r.transfers) return null;
    return r.transfers.find(t => t.sequence === r.currentTransferSequence && t.status !== 'Verified');
  });

  pendingVerification = computed(() => {
    const r = this.rental();
    if (!r || !r.verifications) return null;
    return r.verifications.find(v => v.status === 'Pending');
  });

  currentUserRole = computed(() => {
    if (this.isAdmin()) return 'Expert';
    if (this.isOwner()) return 'Owner';
    if (this.isRenter()) return 'Renter';
    return 'Unknown';
  });

  ngOnInit() {
    this.loadRental();
  }

  loadRental(silent = false) {
    // Only show the full-page spinner on initial load, not on reloads after actions
    if (!silent) this.isLoading.set(true);
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
      case 'awaitingpickup': return 'status-confirmed';
      case 'active':    return 'status-active';
      case 'completed': return 'status-completed';
      case 'cancelled':
      case 'rejected':  return 'status-cancelled';
      case 'overdue':   return 'status-overdue';
      default:          return 'status-default';
    }
  }

  handoffDeliveryMethod = signal<'ByHand' | 'DeliveryService'>('ByHand');

  ownerWantsExpertAtConfirm = false;

  toggleExpert(checked: boolean) {
    this.ownerWantsExpertAtConfirm = checked;
    console.log('Checkbox toggled! ownerWantsExpertAtConfirm is now:', this.ownerWantsExpertAtConfirm);
  }

  confirmRental() {
    this.loadingAction.set('confirmRental');
    
    const executeConfirm = () => {
      console.log('Executing confirm rental API call');
      this.rentalsClient.confirmRental(this.rentalId()).subscribe({
        next: (res: any) => {
          if (res && res.error) {
            let msg = 'errors.generic';
            if (res.messages && res.messages.length > 0) {
              msg = res.messages[0];
            }
            this.toast.showError(msg);
            this.loadingAction.set(null);
            return;
          }
          this.toast.showSuccess('rentals.actions.confirm_success');
          this.loadRental(true);
          this.loadingAction.set(null);
        },
        error: (err) => {
          this.toast.showError('errors.generic');
          this.loadingAction.set(null);
        }
      });
    };

    console.log('ownerWantsExpertAtConfirm value is:', this.ownerWantsExpertAtConfirm);
    
    if (this.ownerWantsExpertAtConfirm) {
      console.log('Calling requestExpertReview API...');
      this.rentalsClient.requestExpertReview(this.rentalId()).subscribe({
        next: (res: any) => {
          console.log('requestExpertReview next block hit, checking result...', res);
          if (res && res.error) {
            let msg = 'errors.generic';
            if (res.messages && res.messages.length > 0) {
              msg = res.messages[0];
            }
            this.toast.showError(msg);
            this.loadingAction.set(null);
            return;
          }
          console.log('requestExpertReview succeeded, calling executeConfirm');
          executeConfirm();
        },
        error: (err: any) => { 
          console.error('requestExpertReview failed:', err);
          let msg = 'errors.generic';
          if (err && err.response) {
            try {
              const parsed = JSON.parse(err.response);
              if (parsed.messages && parsed.messages.length > 0) {
                msg = parsed.messages[0];
              } else if (typeof parsed.error === 'string') {
                msg = parsed.error;
              }
            } catch (e) {}
          } else if (err && typeof err === 'string') {
            msg = err;
          }
          this.toast.showError(msg); 
          this.loadingAction.set(null);
        }
      });
    } else {
      console.log('ownerWantsExpertAtConfirm is false, calling executeConfirm directly');
      executeConfirm();
    }
  }

  setHandoffMethod() {
    this.loadingAction.set('setHandoffMethod');
    const body = new SetHandoffMethodBody({ handoffMethod: this.handoffDeliveryMethod() });
    
    this.rentalsClient.setHandoffMethod(this.rentalId(), body).subscribe({
      next: (res: any) => { 
        if (res && res.error) {
          let msg = res.messages && res.messages.length > 0 ? res.messages[0] : 'errors.generic';
          this.toast.showError(msg);
          this.loadingAction.set(null);
          return;
        }
        this.toast.showSuccess('common.success'); 
        this.loadRental(true); 
        this.loadingAction.set(null); 
        if (this.handoffDeliveryMethod() === 'DeliveryService') {
          this.toast.showInfo('rentals.delivery.initiated');
          this.simulateDelivery();
        }
      },
      error: (err: any) => { 
        let msg = 'errors.generic';
        if (err && err.response) {
          try {
            const parsed = JSON.parse(err.response);
            if (parsed.messages && parsed.messages.length > 0) {
              msg = parsed.messages[0];
              this.toast.showError(msg);
              this.loadingAction.set(null);
              return;
            }
          } catch (e) {}
        }
        this.toast.showError(msg); 
        this.loadingAction.set(null);
      }
    });
  }

  cancelRental() {
    this.loadingAction.set('cancelRental');
    this.rentalsClient.cancelRental(this.rentalId()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(true); this.loadingAction.set(null); },
      error: () => { this.toast.showError('errors.generic'); this.loadingAction.set(null); }
    });
  }

  completeRental() {
    this.loadingAction.set('completeRental');
    this.rentalsClient.completeRental(this.rentalId(), this.isDamaged()).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(true); this.loadingAction.set(null); },
      error: () => { this.toast.showError('errors.generic'); this.loadingAction.set(null); }
    });
  }

  verifyTransfer() {
    if (!this.transferCodeInput()) return;
    this.loadingAction.set('verifyTransfer');
    this.rentalsClient.verifyTransfer(this.rentalId(), this.transferCodeInput()).subscribe({
      next: (res: any) => { 
        if (res && res.error) {
          let msg = 'errors.generic';
          if (typeof res.error === 'string') {
            msg = res.error;
          } else if (res.messages && res.messages.length > 0) {
            msg = res.messages[0];
          }
          this.toast.showError(msg);
          this.loadingAction.set(null);
          return;
        }
        this.toast.showSuccess('common.success'); 
        this.transferCodeInput.set('');
        this.loadRental(true); 
        this.loadingAction.set(null); 
      },
      error: (err: any) => { 
        let msg = 'errors.generic';
        if (err && err.response) {
          try {
            const parsed = JSON.parse(err.response);
            if (parsed.messages && parsed.messages.length > 0) {
              msg = parsed.messages[0];
              this.toast.showError(msg);
              this.loadingAction.set(null);
              return;
            }
          } catch (e) {}
        } else if (err && err.messages && err.messages.length > 0) {
          msg = err.messages[0];
          this.toast.showError(msg);
          this.loadingAction.set(null);
          return;
        }
        this.toast.showError(msg); 
        this.loadingAction.set(null); 
      }
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
      // Prioritize explicit possession tracking if available and not default
      const cp = r.currentPossession?.toString()?.toLowerCase();
      if (cp && cp !== 'none') {
        if (cp === 'owner') return 'owner';
        if (cp === 'expert') return 'expert';
        if (cp === 'intransit') return 'intransit';
        if (cp === 'renter') return 'renter';
      }

      // Fallbacks for older data
      if (r.verifications?.some(v => v.status?.toLowerCase() === 'pending' && v.checkType?.toLowerCase() === 'beforerent')) {
        return 'expert';
      }
      
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

  returnInProgress = computed(() => {
    const r = this.rental();
    if (!r || !r.transfers) return false;
    return r.transfers.some(t => t.phase === 'Return');
  });

  returnDeliveryMethod = signal<'ByHand' | 'NearestLocation' | 'DeliveryService'>('ByHand');
  showReturnOptions = signal(false);

  confirmDeliveryFromExpert() {
    this.submittingDeliveryFromExpert.set(true);
    this.rentalsClient.generateHandoffFromHubTransfers(this.rentalId(), this.selectedDeliveryMethodFromExpert()).subscribe({
      next: (res: any) => {
        if (res && res.error) {
          this.toast.showError(res.messages && res.messages.length > 0 ? res.messages[0] : 'errors.generic');
        } else {
          this.toast.showSuccess('common.success');
          this.loadRental(true);
        }
        this.submittingDeliveryFromExpert.set(false);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.submittingDeliveryFromExpert.set(false);
      }
    });
  }

  initiateReturn() {
    this.showReturnOptions.set(true);
  }

  updatePossession(action: string, method: string, loadingKey: string = 'initiateReturn') {
    this.loadingAction.set(loadingKey as any);
    this.rentalsClient.updatePossession(this.rentalId(), action, method).subscribe({
      next: (res: any) => {
        if (res && res.error) {
          let msg = res.messages && res.messages.length > 0 ? res.messages[0] : 'errors.generic';
          this.toast.showError(msg);
          this.loadingAction.set(null);
          return;
        }
        this.toast.showSuccess('common.success');
        this.loadRental(true);
        this.loadingAction.set(null);
        this.showReturnOptions.set(false);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.loadingAction.set(null);
      }
    });
  }

  confirmReceipt() {
    this.updatePossession('confirm_receipt', 'ByHand', 'confirmReceipt');
  }

  confirmReturn() {
    this.loadingAction.set('confirmReturn');
    const method = this.returnDeliveryMethod();

    if (this.isRenter()) {
      this.rentalsClient.updatePossession(this.rentalId(), 'initiate_return', method).subscribe({
        next: (res: any) => {
          if (res && res.error) {
            let msg = res.messages && res.messages.length > 0 ? res.messages[0] : 'errors.generic';
            this.toast.showError(msg);
            this.loadingAction.set(null);
            return;
          }
          if (method === 'DeliveryService') {
            this.toast.showSuccess('rentals.delivery.initiated');
            this.simulateReturnDelivery();
          } else if (method === 'NearestLocation') {
            this.toast.showSuccess('rentals.nearest_location.confirmed');
          } else {
            this.toast.showSuccess('rentals.return.confirmed');
          }
          this.loadRental(true);
          this.showReturnOptions.set(false);
          this.loadingAction.set(null);
        },
        error: () => {
          this.toast.showError('errors.generic');
          this.loadingAction.set(null);
        }
      });
    } else {
      this.rentalsClient.completeRental(this.rentalId(), this.isDamaged()).subscribe({
        next: () => {
          this.toast.showSuccess('rentals.return.confirmed');
          this.loadRental(true);
          this.showReturnOptions.set(false);
          this.loadingAction.set(null);
        },
        error: () => {
          this.toast.showError('errors.generic');
          this.loadingAction.set(null);
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
      this.rentalsClient.getRentalById(this.rentalId()).subscribe({
        next: (res) => {
          if (res.data) {
            const transfer = res.data.transfers?.find(t => t.sequence === res.data!.currentTransferSequence && t.fromActorType === 'DeliveryAgent');
            if (transfer && transfer.verificationCode) {
              this.rentalsClient.verifyTransfer(this.rentalId(), transfer.verificationCode).subscribe({
                next: () => this.loadRental(true),
                error: () => this.loadRental(true)
              });
            } else {
              this.loadRental(true);
            }
          }
        }
      });
    }, 6000);
  }

  cancelReturnOptions() {
    this.showReturnOptions.set(false);
  }

  hasExpertToOwnerTransfers(): boolean {
    const r = this.rental();
    if (!r || !r.transfers) return false;
    return r.transfers.some(t => t.phase === 'Return' && t.fromActorType === 'Expert');
  }

  confirmExpertToOwnerReturn() {
    this.loadingAction.set('expertReturn');
    const method = this.returnDeliveryMethod();
    this.rentalsClient.generateExpertToOwnerTransfers(this.rentalId(), method).subscribe({
      next: (res: any) => {
        this.loadingAction.set(null);
        if (res.success || !res.error) {
          this.toast.showSuccess('buttons.saved');
          this.loadRental(true);
        } else {
          this.toast.showError(res.error || 'errors.generic');
        }
      },
      error: (err: any) => {
        this.loadingAction.set(null);
        this.toast.showError('errors.generic');
      }
    });
  }

  requestExpertReview() {
    this.loadingAction.set('requestExpertReview');
    this.rentalsClient.requestExpertReview(this.rentalId()).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental(true);
        this.loadingAction.set(null);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.loadingAction.set(null);
      }
    });
  }

  cancelExpertReview() {
    this.loadingAction.set('cancelExpertReview');
    this.rentalsClient.cancelExpertReview(this.rentalId()).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental(true);
        this.loadingAction.set(null);
      },
      error: () => {
        this.toast.showError('errors.generic');
        this.loadingAction.set(null);
      }
    });
  }

  chooseDelivery() {
    this.updatePossession('send_to_expert', 'DeliveryService', 'chooseDelivery');
    this.simulateDelivery();
  }

  chooseNearestLocation() {
    this.updatePossession('send_to_expert', 'NearestLocation', 'chooseNearestLocation');
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
      this.rentalsClient.getRentalById(this.rentalId()).subscribe({
        next: (res) => {
          if (res.data) {
            const transfer = res.data.transfers?.find(t => t.sequence === res.data!.currentTransferSequence && t.fromActorType === 'DeliveryAgent');
            if (transfer && transfer.verificationCode) {
              this.rentalsClient.verifyTransfer(this.rentalId(), transfer.verificationCode).subscribe({
                next: () => this.loadRental(true),
                error: () => this.loadRental(true)
              });
            } else {
              this.loadRental(true);
            }
          }
        }
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
    
    const type = typeStr === 'Handover' ? RentalImageType.Handover : RentalImageType.Return;
    this.isUploading.set(true);

    const uploadObservables = Array.from(input.files).map(file => {
      const fileParam: FileParameter = { data: file, fileName: file.name };
      return this.mediaClient.uploadMedia(this.rentalId(), 'Rental', fileParam);
    });

    forkJoin(uploadObservables).subscribe({
      next: (responses) => {
        const imageIds = responses
          .map(res => res.data?.id)
          .filter((id): id is string => !!id);

        if (imageIds.length > 0) {
          const cmd = new UploadRentalPhotosBody({
            imageIds: imageIds,
            type: type
          });
          this.rentalsClient.uploadRentalPhotos(this.rentalId(), cmd).subscribe({
            next: () => {
              this.toast.showSuccess('common.success');
              this.loadRental(true);
              this.isUploading.set(false);
              input.value = ''; // Clear input
            },
            error: () => {
              this.toast.showError('errors.uploadFailed');
              this.isUploading.set(false);
              input.value = '';
            }
          });
        } else {
          this.isUploading.set(false);
          input.value = '';
        }
      },
      error: () => {
        this.toast.showError('errors.uploadFailed');
        this.isUploading.set(false);
        input.value = '';
      }
    });
  }

  deletePhoto(url: string) {
    if (!confirm(this.translate.instant('common.confirm_delete') || 'Are you sure you want to delete this photo?')) return;
    
    this.isUploading.set(true);
    this.http.delete(`${environment.apiUrl}/api/v1/rentals/${this.rentalId()}/photos?imageUrl=${encodeURIComponent(url)}`).subscribe({
      next: () => {
        this.toast.showSuccess('common.success');
        this.loadRental(true);
        this.isUploading.set(false);
      },
      error: () => {
        this.toast.showError('errors.deleteFailed');
        this.isUploading.set(false);
      }
    });
  }

  setRating(value: number) {
    this.reviewRating.set(value);
  }

  submitReview() {
    if (this.reviewRating() < 1) return;

    this.loadingAction.set('submitReview');
    this.reviewsClient.createReview(this.rentalId(), new CreateReviewCommand({
      rentalId: this.rentalId(),
      rating: this.reviewRating(),
      comment: this.reviewComment()
    })).subscribe({
      next: () => { this.toast.showSuccess('common.success'); this.loadRental(true); this.loadingAction.set(null); },
      error: () => { this.toast.showError('errors.generic'); this.loadingAction.set(null); }
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

    this.loadingAction.set('startChat');
    this.chatClient.createChat(cmd).subscribe({
      next: (res: any) => {
        const chatId = res?.data?.chatId || (res?.data as any)?.id;
        if (chatId) {
          this.router.navigate(['/chats', chatId]);
        }
        this.loadingAction.set(null);
      },
      error: (err: any) => {
        console.error('Failed to start chat', err);
        this.toast.showError('errors.generic');
        this.loadingAction.set(null);
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
        this.loadRental(true);
      }
    });
  }
}
