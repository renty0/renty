import { Component, OnInit, ChangeDetectorRef, inject } from '@angular/core';
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
    private router = inject(Router);
    private supportClient = inject(SupportClient);
    private authService = inject(AuthService);
    private cdr = inject(ChangeDetectorRef);
  availableColumns = ['ticketId', 'relatedItem', 'reportedBy', 'status', 'createdAt', 'actions'];
  myColumns = ['ticketId', 'relatedItem', 'reportedBy', 'status', 'createdAt', 'actions'];
  
  availableDisputes: TicketListDto[] = [];
  myDisputes: TicketListDto[] = [];
  isLoading = true;

  ngOnInit() {
    this.loadDisputes();
  }

  loadDisputes() {
    this.isLoading = true;
    this.cdr.detectChanges();

    this.supportClient.getSupportTickets().subscribe({
      next: (res) => {
        if (res.data && res.data.tickets) {
          const currentUserId = this.authService.getUserData()?.id;
          const allDisputes = res.data.tickets.filter(t => t.type?.toLowerCase() === 'rental');
          
          // Open status and not resolved
          const openDisputes = allDisputes.filter(t => t.status?.toLowerCase() !== 'resolved' && t.status?.toLowerCase() !== 'closed');
          
          this.availableDisputes = openDisputes.filter(t => 
            (t.status?.toLowerCase() === 'open' || t.status?.toLowerCase() === 'escalated') && !t.assignedAgentId
          );
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

  viewDispute(id: string) {
    this.router.navigate(['/admin/disputes/details', id]);
  }
}
