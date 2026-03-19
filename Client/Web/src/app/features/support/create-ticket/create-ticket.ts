import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { SupportClient, CreateTicketCommand, ApiResponse, SupportCreateTicketData } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ToastService } from '../../../shared/services/toast.service';
import { finalize, tap } from 'rxjs';

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
    HeaderSectionComponent
  ],
  templateUrl: './create-ticket.html',
  styleUrl: './create-ticket.scss'
})
export class CreateTicketComponent {
  private supportClient = inject(SupportClient);
  private toast = inject(ToastService);
  private router = inject(Router);

  ticketType = signal('Issue');
  message = signal('');
  isSubmitting = signal(false);

  types = [
    { value: 'Issue', label: 'support.issue' },
    { value: 'Feedback', label: 'support.feedback' },
    { value: 'Inquiry', label: 'support.inquiry' },
    { value: 'Other', label: 'support.other' }
  ];

  submit() {
    if (!this.message().trim() || this.isSubmitting()) return;

    this.isSubmitting.set(true);
    const command = new CreateTicketCommand({
      type: this.ticketType(),
      message: this.message()
    });

    this.supportClient.createSupportTicket(command)
      .pipe(
        tap((res: ApiResponse<SupportCreateTicketData>) => {
          if (!res.error && res.data) {
            this.toast.showSuccess('support.create_success');
            this.router.navigate(['/support', res.data.ticketId]);
          }
        }),
        finalize(() => this.isSubmitting.set(false))
      ).subscribe();
  }
}
