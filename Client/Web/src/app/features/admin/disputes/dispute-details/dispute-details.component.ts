import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { SupportClient, RentalsClient, TicketDetailsDto, RentalDetailDto } from '../../../../core/api/api-client';
import { AgentDashboardComponent } from '../../../support/agent-dashboard/agent-dashboard.component';

@Component({
  selector: 'app-dispute-details',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    MatProgressSpinnerModule,
    MatDialogModule,
    TranslateModule
  ],
  templateUrl: './dispute-details.component.html',
  styleUrl: './dispute-details.component.scss'
})
export class DisputeDetailsComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private supportClient = inject(SupportClient);
  private rentalsClient = inject(RentalsClient);
  private dialog = inject(MatDialog);
  public translate = inject(TranslateService);

  ticketId = signal<string>('');
  ticket = signal<TicketDetailsDto | null>(null);
  rental = signal<RentalDetailDto | null>(null);
  isLoading = signal(true);
  errorMsg = signal<string | null>(null);

  ngOnInit() {
    this.route.paramMap.subscribe(params => {
      const id = params.get('id');
      if (id) {
        this.ticketId.set(id);
        this.loadDetails(id);
      } else {
        this.router.navigate(['/admin/disputes/open']);
      }
    });
  }

  loadDetails(id: string) {
    this.isLoading.set(true);
    this.supportClient.getSupportTicketDetails(id).subscribe({
      next: (res) => {
        if (res.data?.ticket) {
          this.ticket.set(res.data.ticket);
          const rentalId = (res.data.ticket as any).relatedRentalId;
          
          if (rentalId) {
            this.rentalsClient.getRentalById(rentalId).subscribe({
              next: (rentalRes) => {
                this.rental.set(rentalRes.data || null);
                this.isLoading.set(false);
              },
              error: (err) => {
                console.error('Error loading rental details', err);
                this.isLoading.set(false);
              }
            });
          } else {
            this.isLoading.set(false);
          }
        } else {
          this.errorMsg.set('Dispute not found');
          this.isLoading.set(false);
        }
      },
      error: (err) => {
        console.error('Error loading dispute', err);
        this.errorMsg.set('Failed to load dispute details');
        this.isLoading.set(false);
      }
    });
  }

  openSolveDialog() {
    const currentTicket = this.ticket();
    if (!currentTicket || !(currentTicket as any).relatedRentalId) return;

    const dialogRef = this.dialog.open(AgentDashboardComponent, {
      width: '600px',
      data: { rentalId: (currentTicket as any).relatedRentalId }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        // Refresh details after resolution
        this.loadDetails(this.ticketId());
      }
    });
  }

  getSenderName(senderId?: number): string {
    if (!senderId) return 'System';
    const r = this.rental();
    if (r) {
      if (senderId === r.renterId) return `${r.renterFirstName} (Renter)`;
      if (senderId === r.ownerId) return `${r.ownerFirstName} (Owner)`;
      if (senderId === r.assignedExpertId) return `${r.assignedExpertName} (Expert)`;
    }
    const t = this.ticket();
    if (t && senderId === t.assignedAgentId) return `${t.assignedAgentName} (Agent)`;
    
    // Fallback if not matched
    return 'Agent / System';
  }

  isUserMessage(senderId?: number): boolean {
    if (!senderId) return false;
    const r = this.rental();
    if (r) {
      return senderId === r.renterId || senderId === r.ownerId;
    }
    // If no rental context, assume anything not assignedAgentId is a user
    const t = this.ticket();
    if (t && t.assignedAgentId) {
       return senderId !== t.assignedAgentId;
    }
    return true; 
  }

  goBack() {
    this.router.navigate(['/admin/disputes/open']);
  }
}
