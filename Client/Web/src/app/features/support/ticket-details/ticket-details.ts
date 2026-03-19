import { Component, inject, OnInit, signal, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
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
import { SupportClient, TicketDetailsDto, ApiResponse, GetTicketResponse, SupportMessageDto, PostSupportMessageCommand, SupportMessageData, UpdateTicketStatusCommand, SupportTicketStatusData } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { finalize, tap } from 'rxjs';

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
    MatProgressSpinnerModule
  ],
  templateUrl: './ticket-details.html',
  styleUrl: './ticket-details.scss'
})
export class TicketDetailsComponent implements OnInit, AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;

  private route = inject(ActivatedRoute);
  private supportClient = inject(SupportClient);
  private auth = inject(AuthService);

  ticketId = signal('');
  ticket = signal<TicketDetailsDto | null>(null);
  newMessage = signal('');
  isLoading = signal(true);
  isSending = signal(false);
  isUpdatingStatus = signal(false);
  currentUserId = signal<number | null>(null);
  isSupport = this.auth.isSupport.bind(this.auth);

  ngOnInit() {
    this.ticketId.set(this.route.snapshot.paramMap.get('id') || '');
    this.currentUserId.set(this.auth.getCurrentUserId());

    if (this.ticketId()) {
      this.loadTicketDetails();
    }
  }

  ngAfterViewChecked() {
    this.scrollToBottom();
  }

  loadTicketDetails() {
    this.isLoading.set(true);
    this.supportClient.getSupportTicketDetails(this.ticketId())
      .pipe(
        tap((res: ApiResponse<GetTicketResponse>) => {
          if (res.data?.ticket) {
            this.ticket.set(res.data.ticket);
          }
        }),
        finalize(() => {
          this.isLoading.set(false);
          setTimeout(() => this.scrollToBottom(), 100);
        })
      ).subscribe();
  }

  sendReply() {
    if (!this.newMessage().trim() || this.isSending()) return;

    this.isSending.set(true);
    const command = new PostSupportMessageCommand({
      ticketId: this.ticketId(),
      message: this.newMessage()
    });

    this.supportClient.postSupportMessage(this.ticketId(), command)
      .pipe(
        tap((res: ApiResponse<SupportMessageData>) => {
          if (!res.error && res.data) {
            const newMsg = new SupportMessageDto({
              id: res.data.messageId,
              message: res.data.message,
              createdAt: res.data.createdAt,
              senderId: this.currentUserId() || 0
            });
            
            this.ticket.update(t => {
              if (t) {
                return { ...t, messages: [...(t.messages || []), newMsg] } as TicketDetailsDto;
              }
              return t;
            });
            this.newMessage.set('');
          }
        }),
        finalize(() => this.isSending.set(false))
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

  updateStatus(newStatus: string): void {
    if (this.isUpdatingStatus()) return;

    this.isUpdatingStatus.set(true);
    const command = new UpdateTicketStatusCommand({ status: newStatus });
    
    this.supportClient.updateSupportTicketStatus(this.ticketId(), command)
      .pipe(
        tap((res: ApiResponse<SupportTicketStatusData>) => {
          if (!res.error && res.data?.status) {
            this.ticket.update(t => {
              if (t) return { ...t, status: res.data!.status } as TicketDetailsDto;
              return t;
            });
          }
        }),
        finalize(() => this.isUpdatingStatus.set(false))
      ).subscribe();
  }

  getStatusColor(status: string | undefined): string {
    switch (status?.toLowerCase()) {
      case 'open': return 'primary';
      case 'resolved': return 'accent';
      case 'closed': return 'warn';
      default: return '';
    }
  }
}
