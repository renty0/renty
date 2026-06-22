import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { SupportClient, TicketListDto } from '../../../../core/api/api-client';

@Component({
  selector: 'app-resolved-disputes',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatIconModule, TranslateModule],
  templateUrl: './resolved-disputes.component.html',
  styleUrl: './resolved-disputes.component.scss'
})
export class ResolvedDisputesComponent implements OnInit {
  displayedColumns = ['ticketId', 'relatedItem', 'resolutionDate', 'resolvedBy', 'decision', 'reason'];
  resolvedDisputes: TicketListDto[] = [];

  constructor(private supportClient: SupportClient) {}

  ngOnInit() {
    this.supportClient.getSupportTickets().subscribe({
      next: (res) => {
        if (res.data && res.data.tickets) {
          const allDisputes = res.data.tickets.filter(t => t.type?.toLowerCase() === 'rental');
          
          this.resolvedDisputes = allDisputes.filter(t => t.status?.toLowerCase() === 'resolved' || t.status?.toLowerCase() === 'closed');
        }
      },
      error: (err) => console.error('Error loading resolved disputes', err)
    });
  }
}
