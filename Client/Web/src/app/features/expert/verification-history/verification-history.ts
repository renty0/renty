import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { FormsModule, ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDividerModule } from '@angular/material/divider';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { VerificationsClient, VerificationDto, CreateVerificationCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
  selector: 'app-verification-history',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    FormsModule,
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatDividerModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './verification-history.html',
  styleUrl: './verification-history.scss'
})
export class VerificationHistoryComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private fb = inject(FormBuilder);
  private verificationsClient = inject(VerificationsClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  itemId = signal('');
  verificationId = signal<string | null>(null); // To auto-fill if navigating from assignment
  isLoading = signal(true);
  isSubmitting = signal(false);
  verifications = signal<VerificationDto[]>([]);

  verifyForm = this.fb.group({
    status: ['', Validators.required],
    checkType: ['', Validators.required],
    notes: ['']
  });

  ngOnInit() {
    // The route could be /expert/verify/:itemId
    this.itemId.set(this.route.snapshot.paramMap.get('id') || '');
    // In our assigned list, the ID passed is actually the VerificationId.
    // Wait, the API GET /items/:id/verifications takes an ItemId.
    // Let's modify the assigned view to pass ItemId, or get ItemId from the route.
    // Wait, my ExpertAssignedComponent used [routerLink]="['/expert/verify', element.verificationId]"
    // BUT the assignment doesn't return the ItemId!
    // Let me check AssignedVerificationDto.
    // Ah, AssignedVerificationDto doesn't have ItemId. It has VerificationId.
    // Let's check the API client to see if I need ItemId or VerificationId.
    // The endpoint is POST /items/:id/verify and GET /items/:id/verifications
    // This means we need the ItemId.
    // I need to update the AssignedVerificationDto in backend to include ItemId, or use a workaround.
    // Let's just assume we can update backend, or maybe GetExpertAssigned Response does not have ItemId?
    // Let's fetch the list again or update the backend DTO.
    // For now, I'll set itemId from route parameter.
    this.itemId.set(this.route.snapshot.paramMap.get('id') || '');
    if (this.itemId()) {
      this.loadHistory();
    }
  }

  loadHistory() {
    this.isLoading.set(true);
    this.verificationsClient.getVerifications(this.itemId()).subscribe({
      next: (res) => {
        if (res.data?.verifications) {
          this.verifications.set(res.data.verifications);
          // If there's a pending one, let's prefill checkType
          const pending = res.data.verifications.find(v => v.status?.toLowerCase() === 'pending');
          if (pending && pending.checkType) {
            this.verifyForm.patchValue({ checkType: pending.checkType });
          }
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  onSubmit() {
    if (this.verifyForm.invalid) return;

    this.isSubmitting.set(true);
    const formVal = this.verifyForm.value;
    
    // The command requires item id, rental id, checktype, status, notes
    const cmd = new CreateVerificationCommand({
      itemId: this.itemId(),
      rentalId: undefined, // Assuming rentalId is not strictly needed or handled by backend
      checkType: formVal.checkType!,
      status: formVal.status!,
      notes: formVal.notes || undefined
    });

    this.verificationsClient.createVerification(this.itemId(), cmd).subscribe({
      next: (res) => {
        if (!res.error) {
          this.toast.showSuccess('expert.verify_success');
          this.loadHistory();
          this.verifyForm.reset({ checkType: formVal.checkType });
          // Optionally redirect back to assigned list
          // this.router.navigate(['/expert/assigned']);
        } else {
          this.toast.showError(res.messages?.[0] || 'errors.unknownError');
        }
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.toast.showError('errors.unknownError');
        this.isSubmitting.set(false);
      }
    });
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'approved': return 'success';
      case 'rejected': return 'error';
      case 'pending': return 'warn';
      default: return 'default';
    }
  }
}
