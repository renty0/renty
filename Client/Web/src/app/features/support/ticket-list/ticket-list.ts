import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTabsModule } from '@angular/material/tabs';
import { rxResource } from '@angular/core/rxjs-interop';
import { SupportClient } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';

@Component({
  selector: 'app-ticket-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatTabsModule,
    HeaderSectionComponent
  ],
  templateUrl: './ticket-list.html',
  styleUrl: './ticket-list.scss'
})
export class TicketListComponent {
  private readonly supportClient = inject(SupportClient);
  private readonly auth = inject(AuthService);

  isSupport = signal(this.auth.isSupport());
  
  ticketsResource = rxResource({
    stream: () => this.supportClient.getSupportTickets()
  });

  tickets = computed(() => this.ticketsResource.value()?.data?.tickets || []);
  isLoading = computed(() => this.ticketsResource.isLoading());
  
  availableTickets = computed(() => this.tickets().filter(t => !t.assignedAgentId));
  myTickets = computed(() => {
    const currentUserId = this.auth.getCurrentUserId();
    return this.tickets().filter(t => t.assignedAgentId === currentUserId);
  });
  
  isActionLoading = signal<string | null>(null);

  assignToMe(ticketId: string): void {
    if (!ticketId) return;
    this.isActionLoading.set(ticketId);
    this.supportClient.assignSupportTicket(ticketId).subscribe({
      next: () => {
        this.ticketsResource.reload();
        this.isActionLoading.set(null);
      },
      error: () => {
        this.isActionLoading.set(null);
      }
    });
  }
  
  displayedColumns = computed(() => {
    const base = ['id', 'type', 'status', 'createdAt', 'actions'];
    return this.isSupport() ? ['id', 'user', 'type', 'status', 'createdAt', 'actions'] : base;
  });

  skeletonData = [1, 2, 3, 4, 5];

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
