import { Component, OnInit, OnDestroy, signal, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { SupportClient, TicketDetailsDto } from '../../../core/api/api-client';
import { ChatRoomComponent } from '../../chat/chat-room/chat-room';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import * as signalR from '@microsoft/signalr';
import { environment } from '../../../../environments/environment';
import { AuthService } from '../../../core/services/auth.service';
import { PostSupportMessageCommand, UpdateTicketStatusCommand } from '../../../core/api/api-client';

@Component({
  selector: 'app-support-ticket-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, TranslateModule, ChatRoomComponent],
  templateUrl: './ticket-detail.html',
  styleUrls: ['./ticket-detail.scss']
})
export class TicketDetail implements OnInit, OnDestroy {
  ticketId = '';
  ticket = signal<TicketDetailsDto | null>(null);
  isLoading = signal(true);
  private hubConnection: signalR.HubConnection | null = null;
  currentUserId: number | null = null;
  statusDropdownOpen = signal(false);

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: Event) {
    if (this.statusDropdownOpen()) {
      this.statusDropdownOpen.set(false);
    }
  }

  toggleStatusDropdown(event: Event) {
    event.stopPropagation();
    this.statusDropdownOpen.set(!this.statusDropdownOpen());
  }

  selectStatus(status: string) {
    this.updateStatus(status);
    this.statusDropdownOpen.set(false);
  }

  constructor(
    private route: ActivatedRoute,
    private supportClient: SupportClient,
    private authService: AuthService,
    public translate: TranslateService,
    private sanitizer: DomSanitizer
  ) {}

  ngOnInit(): void {
    this.ticketId = this.route.snapshot.paramMap.get('id') || '';
    this.currentUserId = this.authService.getCurrentUserId();
    if (this.ticketId) {
      this.loadTicket();
    }
  }

  ngOnDestroy(): void {
    if (this.hubConnection) {
      this.hubConnection.invoke('LeaveTicket', this.ticketId).catch(err => console.error(err));
      this.hubConnection.stop();
    }
  }

  loadTicket(): void {
    this.supportClient.getSupportTicketDetails(this.ticketId).subscribe({
      next: (res) => {
        if (res && !res.error && res.data && res.data.ticket) {
          this.ticket.set(res.data.ticket);
          this.initSignalR();
        }
        this.isLoading.set(false);
      },
      error: () => {
        this.isLoading.set(false);
      }
    });
  }

  initSignalR(): void {
    const token = this.authService.getToken() || '';
    this.hubConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${environment.apiUrl}/hubs/support`, { accessTokenFactory: () => token })
      .withAutomaticReconnect()
      .build();

    this.hubConnection.on('TicketStatusChanged', (status: string) => {
      const currentTicket = this.ticket();
      if (currentTicket) {
        currentTicket.status = status;
        this.ticket.set({ ...currentTicket } as TicketDetailsDto);
      }
    });

    this.hubConnection.on('ticketstatuschanged', (status: string) => {
      const currentTicket = this.ticket();
      if (currentTicket) {
        currentTicket.status = status;
        this.ticket.set({ ...currentTicket } as TicketDetailsDto);
      }
    });

    this.hubConnection.on('TicketAssignmentChanged', (data: any) => {
      const currentTicket = this.ticket();
      if (currentTicket) {
        currentTicket.assignedAgentId = data.assignedAgentId;
        currentTicket.assignedAgentName = data.assignedAgentName;
        this.ticket.set({ ...currentTicket } as TicketDetailsDto);
      }
    });

    this.hubConnection.on('ticketassignmentchanged', (data: any) => {
      const currentTicket = this.ticket();
      if (currentTicket) {
        currentTicket.assignedAgentId = data.assignedAgentId;
        currentTicket.assignedAgentName = data.assignedAgentName;
        this.ticket.set({ ...currentTicket } as TicketDetailsDto);
      }
    });

    // Add empty listener for joinedticket to prevent warning
    this.hubConnection.on('joinedticket', (ticketId: string) => {
      console.log('Joined ticket', ticketId);
    });

    this.hubConnection.start()
      .then(() => {
        this.hubConnection?.invoke('JoinTicket', this.ticketId).catch(err => console.error(err));
      })
      .catch(err => console.error('SignalR Connection Error: ', err));
  }

  updateStatus(newStatus: string): void {
    const currentTicket = this.ticket();
    if (!currentTicket) return;
    this.supportClient.updateSupportTicketStatus(currentTicket.id!, new UpdateTicketStatusCommand({ ticketId: currentTicket.id, status: newStatus })).subscribe({
      next: (res) => {
        if (res && !res.error) {
          currentTicket.status = newStatus;
          this.ticket.set({ ...currentTicket } as TicketDetailsDto);
          // Refresh timeline by reloading ticket
          this.loadTicket();
        }
      }
    });
  }

  assignToMe(): void {
    const currentTicket = this.ticket();
    if (!currentTicket) return;
    this.supportClient.assignSupportTicket(currentTicket.id!).subscribe({
      next: (res) => {
        if (res) {
          // Trigger timeline refresh
          this.loadTicket();
        }
      }
    });
  }

  getLocalizedEventType(eventType: string | undefined): string {
    if (!eventType) return '';
    if (this.translate.currentLang !== 'ar') return eventType;
    switch (eventType) {
      case 'Created': return 'تم الإنشاء';
      case 'Assigned': return 'تم التعيين';
      case 'Message': return 'رسالة';
      case 'StatusChanged': return 'تغيير الحالة';
      default: return eventType;
    }
  }

  getLocalizedEventDetails(details: string | undefined): string {
    if (!details) return '';
    if (this.translate.currentLang !== 'ar') return details;
    
    if (details === 'Ticket created by user.') return 'تم إنشاء التذكرة بواسطة المستخدم.';
    if (details === 'Ticket assigned to agent.') return 'تم تعيين التذكرة للموظف.';
    if (details === 'Support agent replied.') return 'قام ممثل الدعم بالرد.';
    
    if (details.startsWith('Status changed from ')) {
      const match = details.match(/Status changed from (.*) to (.*)\./);
      if (match) {
        const from = this.translate.instant('support.statuses.' + match[1].toLowerCase());
        const to = this.translate.instant('support.statuses.' + match[2].toLowerCase());
        return `تم تغيير الحالة من ${from} إلى ${to}.`;
      }
    }
    
    return details;
  }

  unassign(): void {
    const currentTicket = this.ticket();
    if (!currentTicket) return;
    this.supportClient.unassignSupportTicket(currentTicket.id!).subscribe({
      next: (res) => {
        if (res && !res.error) {
          this.loadTicket();
        }
      }
    });
  }
}
