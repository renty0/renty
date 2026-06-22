import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { ChatRoomComponent } from '../../../chat/chat-room/chat-room';
import { DisputesClient, SupportClient, ResolveDisputeCommand, RentalsClient } from '../../../../core/api/api-client';

@Component({
  selector: 'app-financial-resolution',
  standalone: true,
  imports: [CommonModule, FormsModule, MatButtonModule, MatIconModule, MatInputModule, MatFormFieldModule, ChatRoomComponent],
  templateUrl: './financial-resolution.component.html',
  styleUrl: './financial-resolution.component.scss'
})
export class FinancialResolutionComponent implements OnInit {
  ticketId: string | null = null;
  rentalId: string | null = null;
  ticketDetails: any = null;

  reason: string = '';
  action: string = '';
  message: string = '';
  messageType: 'success' | 'error' = 'success';
  
  ownerShare: number = 0;
  renterShare: number = 0;

  breakdown = {
    rentalFee: 0,
    deposit: 0,
    expertFee: 0,
    total: 0
  };

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private supportClient: SupportClient,
    private disputesClient: DisputesClient,
    private rentalsClient: RentalsClient
  ) {}

  ngOnInit() {
    this.route.queryParams.subscribe(params => {
      this.ticketId = params['ticketId'];
      this.rentalId = params['rentalId'];
      
      if (this.ticketId) {
        this.supportClient.getSupportTicketDetails(this.ticketId).subscribe(res => {
          if (res.data?.ticket) {
            this.ticketDetails = res.data.ticket;
          }
        });
      }

      if (this.rentalId) {
        this.rentalsClient.getRentalById(this.rentalId).subscribe(res => {
          if (res.data) {
            this.breakdown.rentalFee = res.data.rentalPrice || 0;
            this.breakdown.deposit = res.data.depositAmount || 0;
            this.breakdown.expertFee = 0; // Expert fee not directly available on rental dto
            this.breakdown.total = this.breakdown.rentalFee + this.breakdown.deposit + this.breakdown.expertFee;
          }
        });
      }
    });
  }

  goBack() {
    this.router.navigate(['/admin/disputes/open']);
  }

  setAction(act: string) {
    this.action = act;
  }

  submitAction(act: string) {
    if (!this.reason || this.reason.trim().length === 0) {
      this.showMessage('Mandatory reason is required.', 'error');
      return;
    }
    
    if (!this.rentalId) {
      this.showMessage('No Rental ID available for this dispute.', 'error');
      return;
    }

    let ownerComp = 0;
    let renterRef = 0;
    let decision = '';

    if (act === 'refund') {
      decision = 'refund_renter';
      renterRef = this.breakdown.deposit;
    } else if (act === 'forfeit') {
      decision = 'forfeit_deposit';
      ownerComp = this.breakdown.deposit;
    } else if (act === 'split-confirm') {
      decision = 'split_deposit';
      ownerComp = this.ownerShare;
      renterRef = this.renterShare;
      
      if (ownerComp + renterRef > this.breakdown.deposit) {
        this.showMessage('Split amount exceeds total deposit.', 'error');
        return;
      }
    }

    const cmd = new ResolveDisputeCommand({
      rentalId: this.rentalId,
      resolutionDecision: decision,
      ownerCompensation: ownerComp,
      renterRefund: renterRef,
      reason: this.reason
    });

    this.disputesClient.resolveDispute(cmd).subscribe({
      next: (res) => {
        this.showMessage('Financial resolution recorded successfully.', 'success');
        
        // Also close the support ticket to signify it's done
        if (this.ticketId) {
          this.supportClient.updateSupportTicketStatus(this.ticketId, { status: 'Closed' } as any).subscribe(() => {
            setTimeout(() => {
              this.router.navigate(['/admin/disputes/resolved']);
            }, 1500);
          });
        } else {
          setTimeout(() => {
            this.router.navigate(['/admin/disputes/resolved']);
          }, 1500);
        }
      },
      error: (err) => {
        const errorMsg = err?.response ? JSON.parse(err.response)?.error : 'Failed to resolve dispute.';
        this.showMessage(errorMsg, 'error');
      }
    });
  }

  showMessage(msg: string, type: 'success' | 'error') {
    this.message = msg;
    this.messageType = type;
    setTimeout(() => {
      this.message = '';
    }, 3000);
  }

  dummyAction(actionName: string) {
    this.showMessage(`${actionName} executed successfully (Presentation only).`, 'success');
  }

  returnToSupport() {
    if (!this.ticketId) return;
    
    // First update status to Open
    this.supportClient.updateSupportTicketStatus(this.ticketId, { ticketId: this.ticketId, status: 'Open' } as any).subscribe({
      next: () => {
        // Then unassign
        this.supportClient.unassignSupportTicket(this.ticketId!).subscribe({
          next: () => {
            this.showMessage('Ticket returned to Support queue successfully.', 'success');
            setTimeout(() => {
              this.router.navigate(['/admin/disputes/open']);
            }, 1500);
          },
          error: () => this.showMessage('Failed to unassign ticket.', 'error')
        });
      },
      error: () => this.showMessage('Failed to update ticket status.', 'error')
    });
  }
}
