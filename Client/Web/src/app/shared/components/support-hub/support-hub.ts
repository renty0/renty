import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { PermissionService } from '../../../core/services/permission.service';
import { animate, style, transition, trigger } from '@angular/animations';
import { LiveSupportChatComponent } from '../live-support-chat/live-support-chat';
import { SupportClient } from '../../../core/api/api-client';
import { catchError, of } from 'rxjs';

@Component({
  selector: 'app-support-hub',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule,
    FormsModule,
    LiveSupportChatComponent
  ],
  templateUrl: './support-hub.html',
  styleUrl: './support-hub.scss',
  animations: [
    trigger('hubAnimation', [
      transition(':enter', [
        style({ transform: 'translateY(20px) scale(0.95)', opacity: 0 }),
        animate('300ms cubic-bezier(0.34, 1.56, 0.64, 1)', 
          style({ transform: 'translateY(0) scale(1)', opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms ease-in', 
          style({ transform: 'translateY(20px) scale(0.95)', opacity: 0 }))
      ])
    ])
  ]
})
export class SupportHubComponent {
  private authService = inject(AuthService);
  private permissionService = inject(PermissionService);
  private supportClient = inject(SupportClient);

  isLoggedIn = this.authService.isLoggedIn;
  isOpen = signal(false);
  searchQuery = signal('');

  // Active live chat
  activeLiveChat = signal<{ ticketId: string; subject: string } | null>(null);

  quickActions = [
    { id: 'report', icon: 'report_problem', labelKey: 'support.hub.report', color: '#FF4757' },
    { id: 'payment', icon: 'account_balance_wallet', labelKey: 'support.hub.payment', color: '#2ED573' },
    { id: 'expert', icon: 'psychology', labelKey: 'support.hub.askExpert', color: '#1E90FF' },
    { id: 'guide', icon: 'menu_book', labelKey: 'support.hub.guide', color: '#FFA502' }
  ];

  recentTickets = signal<Array<{ id: string; subject: string; status: string; date: Date }>>([]);

  constructor() {
    // Load real tickets when user is logged in
    if (this.isLoggedIn()) {
      this.loadTickets();
    }
  }

  loadTickets() {
    this.supportClient.getSupportTickets().pipe(
      catchError(() => of(null))
    ).subscribe(res => {
      if (!res?.data?.tickets) return;
      const mapped = res.data.tickets.slice(0, 3).map((t: any) => ({
        id: t.id,
        subject: t.subject,
        status: t.status,
        date: new Date(t.createdAt)
      }));
      this.recentTickets.set(mapped);
    });
  }

  toggleHub() {
    this.isOpen.update(v => !v);
  }

  closeHub() {
    this.isOpen.set(false);
  }

  openLiveChat(ticketId: string, subject: string) {
    this.activeLiveChat.set({ ticketId, subject });
    this.isOpen.set(false); // Close the hub panel when live chat opens
  }

  closeLiveChat() {
    this.activeLiveChat.set(null);
  }

  onAction(actionId: string) {
    if (actionId === 'report' || actionId === 'payment' || actionId === 'expert') {
      this.closeHub();
      // Navigate to new ticket with pre-filled type
    }
  }
}
