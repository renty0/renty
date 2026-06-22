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
import { SupportClient, TicketListDto, UpdateTicketStatusCommand } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-open-disputes',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatButtonModule, MatIconModule, MatTabsModule, MatProgressSpinnerModule, MatMenuModule, TranslateModule],
  template: `
    <div class="expert-assigned-container p-4">
      <div class="flex justify-content-between align-items-center mb-4">
        <h1 class="text-900 font-bold text-3xl">{{ 'ADMIN.DISPUTES.OPEN_DISPUTES' | translate }}</h1>
      </div>

      <div *ngIf="isLoading" class="flex flex-column justify-content-center align-items-center py-8">
        <mat-spinner diameter="60" color="primary"></mat-spinner>
        <p class="mt-4 text-gray-600 font-medium text-lg">{{ 'ADMIN.DISPUTES.LOADING' | translate }}...</p>
      </div>

      <div *ngIf="!isLoading" class="table-container bg-white border-round shadow-2 p-3">
        <mat-tab-group>
          <mat-tab label="{{ 'ADMIN.DISPUTES.AVAILABLE_DISPUTES' | translate }} ({{availableDisputes.length}})">
            <table mat-table [dataSource]="availableDisputes" class="w-full mt-3">
              <ng-container matColumnDef="ticketId">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.TICKET_ID' | translate }}</th>
                <td mat-cell *matCellDef="let dispute" class="font-medium">#{{dispute.id.substring(0, 8)}}</td>
              </ng-container>

              <ng-container matColumnDef="relatedItem">
                <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.RENTAL_ID' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.relatedRentalId?.substring(0, 8) || 'N/A'}}</td>
              </ng-container>

              <ng-container matColumnDef="reportedBy">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.REPORTED_BY' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.userName}}</td>
              </ng-container>

              <ng-container matColumnDef="status">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.STATUS' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">
                  <span class="px-2 py-1 border-round text-sm font-semibold bg-orange-100 text-orange-800">
                    {{ 'SUPPORT.TICKETS.STATUS_TYPES.' + dispute.status.toUpperCase() | translate }}
                  </span>
                </td>
              </ng-container>

              <ng-container matColumnDef="createdAt">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.CREATED_AT' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.createdAt | date:'shortDate'}}</td>
              </ng-container>

              <ng-container matColumnDef="actions">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.ACTIONS' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">
                  <button mat-flat-button color="primary" (click)="assignToMe(dispute.id)">
                    <mat-icon>person_add</mat-icon> {{ 'ADMIN.DISPUTES.ASSIGN_TO_ME' | translate }}
                  </button>
                </td>
              </ng-container>

              <tr mat-header-row *matHeaderRowDef="availableColumns"></tr>
              <tr mat-row *matRowDef="let row; columns: availableColumns;" class="verif-row hover:bg-gray-50"></tr>
              
              <tr class="mat-row" *matNoDataRow>
                <td class="mat-cell text-center py-4 text-gray-500" colspan="6">{{ 'ADMIN.DISPUTES.NO_AVAILABLE' | translate }}</td>
              </tr>
            </table>
          </mat-tab>

          <mat-tab label="{{ 'ADMIN.DISPUTES.MY_DISPUTES' | translate }} ({{myDisputes.length}})">
            <table mat-table [dataSource]="myDisputes" class="w-full mt-3">
              <ng-container matColumnDef="ticketId">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.TICKET_ID' | translate }}</th>
                <td mat-cell *matCellDef="let dispute" class="font-medium">#{{dispute.id.substring(0, 8)}}</td>
              </ng-container>

              <ng-container matColumnDef="relatedItem">
                <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.RENTAL_ID' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.relatedRentalId?.substring(0, 8) || 'N/A'}}</td>
              </ng-container>

              <ng-container matColumnDef="reportedBy">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.REPORTED_BY' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.userName}}</td>
              </ng-container>

              <ng-container matColumnDef="status">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.STATUS' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">
                  <span class="px-2 py-1 border-round text-sm font-semibold bg-blue-100 text-blue-800">
                    {{ 'SUPPORT.TICKETS.STATUS_TYPES.' + dispute.status.toUpperCase() | translate }}
                  </span>
                </td>
              </ng-container>

              <ng-container matColumnDef="createdAt">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.CREATED_AT' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">{{dispute.createdAt | date:'shortDate'}}</td>
              </ng-container>

              <ng-container matColumnDef="actions">
                <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.ACTIONS' | translate }}</th>
                <td mat-cell *matCellDef="let dispute">
                  <button mat-icon-button [matMenuTriggerFor]="actionsMenu" color="primary" [disabled]="dispute.status?.toLowerCase() === 'open'">
                    <mat-icon>more_vert</mat-icon>
                  </button>
                  <mat-menu #actionsMenu="matMenu">
                    <button mat-menu-item (click)="viewChatHistory(dispute)">
                      <mat-icon color="primary">chat</mat-icon>
                      <span>{{ 'ADMIN.DISPUTES.ACTION_VIEW_CHAT' | translate }}</span>
                    </button>
                    <button mat-menu-item (click)="resolveFinancials(dispute)">
                      <mat-icon color="accent">account_balance_wallet</mat-icon>
                      <span>{{ 'ADMIN.DISPUTES.ACTION_RESOLVE' | translate }}</span>
                    </button>
                    <button mat-menu-item (click)="returnToSupport(dispute)">
                      <mat-icon color="warn">keyboard_return</mat-icon>
                      <span>{{ 'ADMIN.DISPUTES.ACTION_RETURN_SUPPORT' | translate }}</span>
                    </button>
                    <button mat-menu-item (click)="closeDispute(dispute)">
                      <mat-icon class="text-gray-500">close</mat-icon>
                      <span>{{ 'ADMIN.DISPUTES.ACTION_CLOSE' | translate }}</span>
                    </button>
                  </mat-menu>
                </td>
              </ng-container>

              <tr mat-header-row *matHeaderRowDef="myColumns"></tr>
              <tr mat-row *matRowDef="let row; columns: myColumns;" class="verif-row hover:bg-gray-50"></tr>
              
              <tr class="mat-row" *matNoDataRow>
                <td class="mat-cell text-center py-4 text-gray-500" colspan="6">{{ 'ADMIN.DISPUTES.NO_ASSIGNED' | translate }}</td>
              </tr>
            </table>
          </mat-tab>
        </mat-tab-group>
      </div>
    </div>
  `
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
