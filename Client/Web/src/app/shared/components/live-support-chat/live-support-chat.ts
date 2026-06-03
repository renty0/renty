import {
  Component, inject, signal, computed, input, output,
  effect, ViewChild, ElementRef, AfterViewChecked, OnDestroy
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { SupportSignalrService, SupportMessage } from '../../../core/services/support-signalr.service';
import { SupportClient, PostSupportMessageCommand } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { animate, style, transition, trigger } from '@angular/animations';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { catchError, of } from 'rxjs';

@Component({
  selector: 'app-live-support-chat',
  standalone: true,
  imports: [CommonModule, FormsModule, TranslateModule, MatIconModule, MatButtonModule],
  templateUrl: './live-support-chat.html',
  styleUrl: './live-support-chat.scss',
  animations: [
    trigger('messageIn', [
      transition(':enter', [
        style({ transform: 'translateY(8px)', opacity: 0 }),
        animate('200ms ease-out', style({ transform: 'translateY(0)', opacity: 1 }))
      ])
    ])
  ]
})
export class LiveSupportChatComponent implements AfterViewChecked, OnDestroy {
  @ViewChild('msgContainer') private msgContainer!: ElementRef;

  // Inputs / Outputs
  ticketId = input.required<string>();
  ticketSubject = input<string>('Support');
  closed = output<void>();

  private supportSignalr = inject(SupportSignalrService);
  private supportClient = inject(SupportClient);
  private authService = inject(AuthService);

  currentUserId = signal(this.authService.getCurrentUserId());
  currentUserName = computed(() => {
    const d = this.authService.getUserData();
    return d ? `${d.firstName} ${d.lastName}` : 'You';
  });

  // All messages (loaded + live)
  messages = signal<SupportMessage[]>([]);
  activeAgents = this.supportSignalr.activeAgents;
  typingUser = this.supportSignalr.typingUser;
  isConnected = this.supportSignalr.isConnected;

  messageText = signal('');
  isSending = signal(false);
  isMinimized = signal(false);
  private shouldScroll = false;

  constructor() {
    // Load existing messages when ticket changes
    effect(() => {
      const id = this.ticketId();
      if (!id) return;
      this.loadHistory(id);
      this.connectToTicket(id);
    });

    // Inject new live messages into the list
    effect(() => {
      const msg = this.supportSignalr.newMessage();
      if (msg && msg.ticketId === this.ticketId()) {
        this.messages.update(msgs => {
          if (msgs.find(m => m.id === msg.id)) return msgs;
          return [...msgs, msg];
        });
        this.shouldScroll = true;
      }
    });
  }

  private async connectToTicket(ticketId: string) {
    await this.supportSignalr.startConnection();
    await this.supportSignalr.joinTicket(ticketId);
  }

  private loadHistory(ticketId: string) {
    this.supportClient.getSupportTicketDetails(ticketId).pipe(
      catchError(() => of(null))
    ).subscribe(res => {
      if (!res?.data?.ticket?.messages) return;
      const mapped: SupportMessage[] = res.data.ticket.messages.map((m: any) => ({
        id: m.id,
        ticketId,
        senderId: m.senderId,
        senderName: m.senderName || 'User',
        senderRole: m.senderRole || 'User',
        message: m.message,
        createdAt: m.createdAt
      }));
      this.messages.set(mapped);
      this.shouldScroll = true;
    });
  }

  ngAfterViewChecked() {
    if (this.shouldScroll) {
      this.scrollToBottom();
      this.shouldScroll = false;
    }
  }

  private scrollToBottom() {
    try {
      const el = this.msgContainer?.nativeElement;
      if (el) el.scrollTop = el.scrollHeight;
    } catch {}
  }

  async sendMessage() {
    const text = this.messageText().trim();
    if (!text || this.isSending()) return;

    this.isSending.set(true);
    const command = new PostSupportMessageCommand({
      ticketId: this.ticketId(),
      message: text
    });

    this.supportClient.postSupportMessage(this.ticketId(), command).pipe(
      catchError(() => of(null))
    ).subscribe(() => {
      this.messageText.set('');
      this.isSending.set(false);
    });
  }

  onKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.sendMessage();
    }
  }

  onTyping() {
    this.supportSignalr.sendTyping(this.ticketId(), this.currentUserName());
  }

  isMyMessage(msg: SupportMessage): boolean {
    return msg.senderId === this.currentUserId();
  }

  isAgentMessage(msg: SupportMessage): boolean {
    return msg.senderRole === 'Support' || msg.senderRole === 'Admin';
  }

  getInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  }

  toggleMinimize() {
    this.isMinimized.update(v => !v);
  }

  closeChat() {
    this.supportSignalr.leaveTicket(this.ticketId());
    this.closed.emit();
  }

  ngOnDestroy() {
    this.supportSignalr.leaveTicket(this.ticketId());
  }
}
