import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { SupportClient, TicketListDto } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { MatTabsModule } from '@angular/material/tabs';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-support-ticket-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    FormsModule,
    TranslateModule,
    MatTabsModule,
    MatTableModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './ticket-list.html',
  styleUrls: ['./ticket-list.scss']
})
export class TicketList implements OnInit {
  availableTickets = signal<TicketListDto[]>([]);
  myTickets = signal<TicketListDto[]>([]);
  isLoading = signal(true);
  isActionLoading = signal(false);

  displayedColumns = ['id', 'user', 'type', 'status', 'age', 'actions'];

  constructor(private supportClient: SupportClient, private authService: AuthService, public translate: TranslateService) {}

  ngOnInit(): void {
    this.loadTickets();
  }

  loadTickets(): void {
    this.isLoading.set(true);
    this.supportClient.getSupportTickets().subscribe({
      next: (res) => {
        if (res && !res.error && res.data && res.data.tickets) {
          const currentUserId = this.authService.getCurrentUserId();
          this.availableTickets.set(res.data.tickets.filter(t => !t.assignedAgentId));
          this.myTickets.set(res.data.tickets.filter(t => t.assignedAgentId === currentUserId));
        }
        this.isLoading.set(false);
      },
      error: () => {
        this.isLoading.set(false);
      }
    });
  }

  assignToMe(ticketId: string): void {
    this.isActionLoading.set(true);
    this.supportClient.assignSupportTicket(ticketId).subscribe({
      next: () => {
        this.isActionLoading.set(false);
        this.loadTickets();
      },
      error: () => {
        this.isActionLoading.set(false);
      }
    });
  }

  getAge(createdAt: Date): string {
    const ms = new Date().getTime() - new Date(createdAt).getTime();
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms / (1000 * 60 * 60)) % 24);
    if (days > 0) return `${days}d ${hours}h`;
    return `${hours}h`;
  }
}
