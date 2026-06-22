import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatMenuModule } from '@angular/material/menu';
import { TranslateModule } from '@ngx-translate/core';
import { SupportClient, TicketListDto, UpdateTicketStatusCommand } from '../../../../core/api/api-client';
import { AuthService } from '../../../../core/services/auth.service';

@Component({
  selector: 'app-open-disputes',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatButtonModule, MatIconModule, MatTabsModule, MatProgressSpinnerModule, MatMenuModule, TranslateModule],
  templateUrl: './open-disputes.component.html',
  styleUrl: './open-disputes.component.scss'
})
export class OpenDisputesComponent implements OnInit {
  availableColumns = ['ticketId', 'relatedItem', 'reportedBy', 'status', 'createdAt', 'actions'];
  myColumns = ['ticketId', 'relatedItem', 'reportedBy', 'status', 'createdAt', 'actions'];
  
  availableDisputes: TicketListDto[] = [];
  myDisputes: TicketListDto[] = [];
  isLoading = true;

  constructor(
    private router: Router,
    private supportClient: SupportClient,
    private authService: AuthService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.loadDisputes();
  }

  loadDisputes() {
    this.isLoading = true;
    this.cdr.detectChanges();

    this.supportClient.getSupportTickets().subscribe({
      next: (res) => {
        if (res.data && res.data.tickets) {
          const currentUserId = this.authService.getUserId();
          const allDisputes = res.data.tickets.filter(t => t.type?.toLowerCase() === 'rental');
          
          // Open status and not resolved
          const openDisputes = allDisputes.filter(t => t.status?.toLowerCase() !== 'resolved' && t.status?.toLowerCase() !== 'closed');
          
          this.availableDisputes = openDisputes.filter(t => t.status?.toLowerCase() === 'open' || t.status?.toLowerCase() === 'escalated');
          this.myDisputes = openDisputes.filter(t => t.assignedAgentId === currentUserId);
        }
        
        setTimeout(() => {
          this.isLoading = false;
          this.cdr.detectChanges();
        });
      },
      error: (err) => {
        console.error('Error loading disputes', err);
        setTimeout(() => {
          this.isLoading = false;
          this.cdr.detectChanges();
        });
      }
    });
  }

  assignToMe(id?: string) {
    if (!id) return;
    this.supportClient.assignSupportTicket(id).subscribe({
      next: () => this.loadDisputes(),
      error: (err) => console.error('Error assigning dispute', err)
    });
  }

  resolveFinancials(dispute: TicketListDto) {
    alert('Not implemented yet');
  }

  viewChatHistory(dispute: TicketListDto) {
    alert('Not implemented yet');
  }

  returnToSupport(dispute: TicketListDto) {
    alert('Not implemented yet');
  }

  closeDispute(dispute: TicketListDto) {
    if (!dispute.id) return;
    
    // Setting status to 'Open' as requested by the user
    const cmd = new UpdateTicketStatusCommand({
      ticketId: dispute.id,
      status: 'Open'
    });
    
    this.supportClient.updateSupportTicketStatus(dispute.id, cmd).subscribe({
      next: () => {
        this.loadDisputes(); // reload the table to reflect the change
      },
      error: (err) => {
        console.error('Error closing dispute', err);
        alert('Failed to change dispute status');
      }
    });
  }
}
