import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { ChatRoomComponent } from '../../chat/chat-room/chat-room';
import { DisputesClient, SupportClient, ResolveDisputeCommand, RentalsClient } from '../../../core/api/api-client';

@Component({
  selector: 'app-financial-resolution',
  standalone: true,
  imports: [CommonModule, FormsModule, MatButtonModule, MatIconModule, MatInputModule, MatFormFieldModule, ChatRoomComponent],
  template: `
    <div class="expert-assigned-container p-4 max-w-6xl mx-auto">
      <!-- Error/Success Message Placeholder -->
      <div *ngIf="message" class="p-3 mb-4 border-round text-white font-medium shadow-1" 
           [ngClass]="messageType === 'error' ? 'bg-red-500' : 'bg-green-500'">
        <mat-icon class="vertical-align-middle mr-2">{{messageType === 'error' ? 'error' : 'check_circle'}}</mat-icon>
        {{message}}
      </div>

      <div class="flex justify-content-between align-items-center mb-5">
        <h1 class="text-900 font-bold text-3xl m-0">Financial Resolution - Ticket #{{ticketId?.substring(0, 8)}}</h1>
        <button mat-button color="primary" (click)="goBack()">
          <mat-icon>arrow_back</mat-icon> Back to Open Disputes
        </button>
      </div>

      <div class="grid mb-4 gap-4">
        <div class="col-12 lg:col-7 p-0 flex flex-column gap-4">
          <div class="grid m-0 gap-4">
            <div class="col-12 md:col-6 p-0">
              <div class="bg-white p-4 border-round shadow-1 h-full">
                <h3 class="mt-0 text-primary mb-4 flex align-items-center"><mat-icon class="mr-2">account_balance</mat-icon> Escrow Breakdown</h3>
                <ul class="list-none p-0 m-0 text-lg">
                  <li class="flex justify-content-between mb-3 border-bottom-1 surface-border pb-2">
                    <span class="text-color-secondary">Rental Fee:</span> 
                    <strong class="text-900">{{breakdown.rentalFee | currency}}</strong>
                  </li>
                  <li class="flex justify-content-between mb-3 border-bottom-1 surface-border pb-2">
                    <span class="text-color-secondary">Deposit Held:</span> 
                    <strong class="text-900">{{breakdown.deposit | currency}}</strong>
                  </li>
                  <li class="flex justify-content-between mb-3 border-bottom-1 surface-border pb-2">
                    <span class="text-color-secondary">Expert Fee:</span> 
                    <strong class="text-900">{{breakdown.expertFee | currency}}</strong>
                  </li>
                  <li class="flex justify-content-between mt-4 text-xl">
                    <span class="font-bold text-primary">Total Escrow:</span> 
                    <strong class="text-primary">{{breakdown.total | currency}}</strong>
                  </li>
                </ul>
              </div>
            </div>
            <div class="col-12 md:col-5 p-0">
              <div class="bg-white p-4 border-round shadow-1 h-full">
                <h3 class="mt-0 text-primary mb-4 flex align-items-center"><mat-icon class="mr-2">people</mat-icon> Dispute Details</h3>
                <div class="mb-3">
                  <div class="text-sm text-color-secondary mb-1">Rental ID</div>
                  <div class="text-lg font-medium">{{rentalId?.substring(0, 8)}}</div>
                </div>
                <div class="mb-3">
                  <div class="text-sm text-color-secondary mb-1">Ticket Status</div>
                  <div class="text-lg font-medium">{{ticketDetails?.status}}</div>
                </div>
                <div>
                  <div class="text-sm text-color-secondary mb-1">Reported By</div>
                  <div class="text-lg font-medium">{{ticketDetails?.userName}}</div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-yellow-50 p-4 border-round border-1 border-yellow-200 shadow-1">
            <h3 class="mt-0 text-yellow-800 flex align-items-center"><mat-icon class="mr-2">gavel</mat-icon> Mandatory Justification</h3>
            <p class="text-yellow-800 mb-3">Please provide a detailed reason for the financial resolution. This will be recorded in the audit logs and visible to all parties.</p>
            
            <mat-form-field appearance="outline" class="w-full">
              <mat-label>Resolution Reason</mat-label>
              <textarea matInput [(ngModel)]="reason" rows="4" placeholder="e.g. Minor cosmetic damage confirmed by expert. Split 50/50."></textarea>
            </mat-form-field>
          </div>

          <div class="grid m-0" *ngIf="action === 'split'">
            <div class="col-12 md:col-6 p-0 pr-2">
              <mat-form-field appearance="outline" class="w-full">
                <mat-label>Owner Share (EGP)</mat-label>
                <input matInput type="number" [(ngModel)]="ownerShare">
              </mat-form-field>
            </div>
            <div class="col-12 md:col-6 p-0 pl-2">
              <mat-form-field appearance="outline" class="w-full">
                <mat-label>Renter Share (EGP)</mat-label>
                <input matInput type="number" [(ngModel)]="renterShare">
              </mat-form-field>
            </div>
          </div>

          <div class="flex gap-3 flex-wrap">
            <button mat-flat-button class="bg-green-600 text-white" [disabled]="!reason" (click)="submitAction('refund')">
              <mat-icon>undo</mat-icon> Approve Full Refund
            </button>
            <button mat-flat-button color="warn" [disabled]="!reason" (click)="submitAction('forfeit')">
              <mat-icon>warning</mat-icon> Forfeit Deposit
            </button>
            <button mat-flat-button class="bg-yellow-600 text-white" [disabled]="!reason" (click)="setAction('split')">
              <mat-icon>call_split</mat-icon> Split Deposit
            </button>
            <button mat-flat-button color="primary" [disabled]="!reason" (click)="setAction('manual')">
              <mat-icon>edit</mat-icon> Manual Adjustment
            </button>
          </div>

          <div *ngIf="action === 'split' || action === 'manual'" class="mt-4 flex gap-3 p-4 bg-gray-50 border-round">
            <button mat-flat-button class="bg-green-600 text-white" [disabled]="!reason" (click)="submitAction('split-confirm')">
              <mat-icon>check_circle</mat-icon> Confirm Custom Split
            </button>
            <button mat-button (click)="action = ''">Cancel</button>
          </div>

          <div class="flex gap-3 flex-wrap mt-4 border-top-1 surface-border pt-4">
            <button mat-stroked-button color="primary" (click)="dummyAction('Send Warning to User')">
              <mat-icon>warning</mat-icon> Send Warning
            </button>
            <button mat-stroked-button color="warn" (click)="dummyAction('Ban User Account')">
              <mat-icon>block</mat-icon> Ban User
            </button>
            <button mat-flat-button class="bg-blue-600 text-white" (click)="returnToSupport()">
              <mat-icon>assignment_return</mat-icon> Return to Support (Open)
            </button>
          </div>
        </div>

        <div class="col-12 lg:col-5 p-0">
          <div class="bg-white border-round shadow-1 h-full flex flex-column" style="overflow: hidden; min-height: 600px;">
            <h3 class="mt-0 text-primary p-4 pb-0 mb-0 flex align-items-center"><mat-icon class="mr-2">forum</mat-icon> Chat History</h3>
            <app-chat-room *ngIf="ticketId" [inputChatId]="ticketId" [isSupport]="true" [disabled]="true" style="flex-grow: 1; display: flex; flex-direction: column;"></app-chat-room>
          </div>
        </div>
      </div>
    </div>
  `
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
