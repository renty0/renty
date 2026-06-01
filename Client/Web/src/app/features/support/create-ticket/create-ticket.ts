import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { SupportClient, CreateTicketCommand, ApiResponse, SupportCreateTicketData } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ToastService } from '../../../shared/services/toast.service';

import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { Subject, finalize, tap, exhaustMap, catchError, of } from 'rxjs';

@Component({
  selector: 'app-create-ticket',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    FormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    HeaderSectionComponent,
    LoadingButtonComponent
  ],
  templateUrl: './create-ticket.html',
  styleUrl: './create-ticket.scss'
})
export class CreateTicketComponent {
  private readonly supportClient = inject(SupportClient);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly toast = inject(ToastService);

  ticketType = signal('General');
  message = signal('');
  isSubmitting = signal(false);

  private readonly submitSubject = new Subject<void>();

  types = [
    { value: 'General', label: 'support.types.general' },
    { value: 'Billing', label: 'support.types.billing' },
    { value: 'Rental', label: 'support.types.rental' },
    { value: 'Payment', label: 'support.types.payment' },
    { value: 'Technical', label: 'support.types.technical' },
    { value: 'Other', label: 'support.types.other' }
  ];

  constructor() {
    // Auto-fill ticket type from quick-action navigation (e.g., ?type=Payment)
    const typeParam = this.route.snapshot.queryParamMap.get('type');
    const validTypes = ['General', 'Billing', 'Rental', 'Payment', 'Technical', 'Other'];
    if (typeParam && validTypes.includes(typeParam)) {
      this.ticketType.set(typeParam);
    }

    this.submitSubject.pipe(
      tap(() => this.isSubmitting.set(true)),
      exhaustMap(() => {
        const command = new CreateTicketCommand({
          type: this.ticketType(),
          message: this.message()
        });

        return this.supportClient.createSupportTicket(command).pipe(
          tap((res: ApiResponse<SupportCreateTicketData>) => {
            if (res.data) {
              this.toast.showSuccess('support.create_success');
              this.router.navigate(['/support', res.data.ticketId]);
            }
          }),
          catchError(() => {
            this.toast.showError('Failed to create ticket');
            return of(null);
          }),
          finalize(() => this.isSubmitting.set(false))
        );
      }),
      takeUntilDestroyed()
    ).subscribe();
  }

  submit() {
    if (!this.message().trim() || this.isSubmitting()) {
      return;
    }
    this.submitSubject.next();
  }
}
