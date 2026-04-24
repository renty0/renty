import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
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
  
  displayedColumns = computed(() => {
    const base = ['id', 'type', 'status', 'createdAt', 'actions'];
    return this.isSupport() ? ['id', 'user', 'type', 'status', 'createdAt', 'actions'] : base;
  });

  skeletonData = [1, 2, 3, 4, 5];

  getStatusColor(status: string | undefined): string {
    switch (status?.toLowerCase()) {
      case 'open': return 'primary';
      case 'awaitingsupport': return 'warn';
      case 'awaitingcustomer': return 'accent';
      case 'resolved': return 'success';
      case 'closed': return 'secondary';
      default: return '';
    }
  }
}
