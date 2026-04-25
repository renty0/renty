import { Component, inject, signal, computed, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatChipsModule } from '@angular/material/chips';
import { MatSelectModule } from '@angular/material/select';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { rxResource, takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { SupportClient, PostSupportMessageCommand, UpdateTicketStatusCommand } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';
import { Subject, finalize, tap, exhaustMap, catchError, of } from 'rxjs';

@Component({
  selector: 'app-ticket-details',
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
    MatChipsModule,
    MatSelectModule,
    MatProgressSpinnerModule,
    LoadingButtonComponent
  ],
  templateUrl: './ticket-details.html',
  styleUrl: './ticket-details.scss'
})
export class TicketDetailsComponent implements AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;

  private readonly route = inject(ActivatedRoute);
  private readonly supportClient = inject(SupportClient);
  private readonly auth = inject(AuthService);
  private readonly toast = inject(ToastService);

  ticketId = signal(this.route.snapshot.paramMap.get('id') || '');
  currentUserId = signal(this.auth.getCurrentUserId());
  isSupport = signal(this.auth.isSupport());
  
  ticketResource = rxResource({
    params: () => ({ id: this.ticketId() }),
    stream: ({ params }) => this.supportClient.getSupportTicketDetails(params.id)
  });

  ticket = computed(() => this.ticketResource.value()?.data?.ticket || null);
  isLoading = computed(() => this.ticketResource.isLoading());
  
  newMessage = signal('');
  isSending = signal(false);
  isUpdatingStatus = signal(false);

  private readonly sendSubject = new Subject<void>();

  constructor() {
    this.sendSubject.pipe(
      tap(() => this.isSending.set(true)),
      exhaustMap(() => {
        const command = new PostSupportMessageCommand({
          ticketId: this.ticketId(),
          message: this.newMessage()
        });

        return this.supportClient.postSupportMessage(this.ticketId(), command).pipe(
          tap((res) => {
            if (res.data) {
              this.newMessage.set('');
              this.ticketResource.reload();
            }
          }),
          catchError(() => {
            this.toast.showError('Failed to send message');
            return of(null);
          }),
          finalize(() => this.isSending.set(false))
        );
      }),
      takeUntilDestroyed()
    ).subscribe();
  }

  ngAfterViewChecked() {
    this.scrollToBottom();
  }

  sendReply() {
    if (!this.newMessage().trim() || this.isSending()) return;
    this.sendSubject.next();
  }

  updateStatus(newStatus: string): void {
    if (this.isUpdatingStatus()) return;

    this.isUpdatingStatus.set(true);
    const command = new UpdateTicketStatusCommand({ status: newStatus });
    
    this.supportClient.updateSupportTicketStatus(this.ticketId(), command)
      .pipe(
        tap((res) => {
          if (res.data) {
            this.ticketResource.reload();
            this.toast.showSuccess('Status updated');
          }
        }),
        catchError(() => {
          this.toast.showError('Failed to update status');
          return of(null);
        }),
        finalize(() => this.isUpdatingStatus.set(false))
      ).subscribe();
  }

  private scrollToBottom(): void {
    try {
      this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
    } catch(err) { }
  }

  isCurrentUser(senderId: number | undefined): boolean {
    return senderId === this.currentUserId();
  }

  getStatusColor(status: string | undefined): string {
    switch (status?.toLowerCase()) {
      case 'open': return 'bg-blue-50 text-blue-700 border-1 border-blue-100';
      case 'awaitingsupport': return 'bg-yellow-50 text-yellow-700 border-1 border-yellow-100';
      case 'awaitingcustomer': return 'bg-indigo-50 text-indigo-700 border-1 border-indigo-100';
      case 'resolved': return 'bg-green-50 text-green-700 border-1 border-green-100';
      case 'closed': return 'bg-gray-50 text-gray-700 border-1 border-gray-100';
      default: return 'bg-gray-50 text-gray-400 border-1 border-gray-100';
    }
  }
}
