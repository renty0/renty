import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { SupportClient, TicketListDto, ApiResponse, GetTicketsResponse } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { finalize, tap } from 'rxjs';

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
export class TicketListComponent implements OnInit {
  private supportClient = inject(SupportClient);
  private auth = inject(AuthService);

  isSupport = () => this.auth.isSupport();
  tickets = signal<TicketListDto[]>([]);
  isLoading = signal(true);
  displayedColumns: string[] = ['id', 'type', 'status', 'createdAt', 'actions'];

  ngOnInit() {
    if (this.isSupport()) {
      this.displayedColumns = ['id', 'user', 'type', 'status', 'createdAt', 'actions'];
    }
    this.loadTickets();
  }

  loadTickets() {
    this.isLoading.set(true);
    this.supportClient.getSupportTickets()
      .pipe(
        tap((res: ApiResponse<GetTicketsResponse>) => {
          if (res.data?.tickets) {
            this.tickets.set(res.data.tickets);
          }
        }),
        finalize(() => this.isLoading.set(false))
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
