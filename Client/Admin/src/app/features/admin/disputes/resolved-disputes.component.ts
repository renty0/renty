import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { SupportClient, TicketListDto } from '../../../core/api/api-client';

@Component({
  selector: 'app-resolved-disputes',
  standalone: true,
  imports: [CommonModule, MatTableModule, MatIconModule, TranslateModule],
  template: `
    <div class="expert-assigned-container p-4">
      <div class="flex justify-content-between align-items-center mb-4">
        <h1 class="text-900 font-bold text-3xl">{{ 'ADMIN.DISPUTES.RESOLVED_DISPUTES' | translate }}</h1>
      </div>

      <div class="table-container bg-white border-round shadow-2 p-3">
        <table mat-table [dataSource]="resolvedDisputes" class="w-full">
          
          <ng-container matColumnDef="ticketId">
            <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.TICKET_ID' | translate }}</th>
            <td mat-cell *matCellDef="let dispute" class="font-medium">#{{dispute.id.substring(0, 8)}}</td>
          </ng-container>

          <ng-container matColumnDef="relatedItem">
            <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.RENTAL_ID' | translate }}</th>
            <td mat-cell *matCellDef="let dispute">{{dispute.relatedRentalId?.substring(0, 8) || 'N/A'}}</td>
          </ng-container>

          <ng-container matColumnDef="resolutionDate">
            <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.RESOLUTION_DATE' | translate }}</th>
            <td mat-cell *matCellDef="let dispute">{{dispute.updatedAt | date:'medium'}}</td>
          </ng-container>

          <ng-container matColumnDef="resolvedBy">
            <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.RESOLVED_BY' | translate }}</th>
            <td mat-cell *matCellDef="let dispute">{{dispute.assignedAgentName || 'Admin'}}</td>
          </ng-container>

          <ng-container matColumnDef="decision">
            <th mat-header-cell *matHeaderCellDef>{{ 'SUPPORT.TICKETS.STATUS' | translate }}</th>
            <td mat-cell *matCellDef="let dispute">
              <span class="px-2 py-1 border-round text-sm font-semibold bg-green-100 text-green-800">
                {{ 'SUPPORT.TICKETS.STATUS_TYPES.' + dispute.status.toUpperCase() | translate }}
              </span>
            </td>
          </ng-container>

          <ng-container matColumnDef="reason">
            <th mat-header-cell *matHeaderCellDef>{{ 'ADMIN.DISPUTES.FINAL_MESSAGE' | translate }}</th>
            <td mat-cell *matCellDef="let dispute" class="text-color-secondary">{{dispute.lastMessage || ('ADMIN.DISPUTES.CLOSED_BY_ADMIN' | translate) }}</td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
          <tr mat-row *matRowDef="let row; columns: displayedColumns;" class="verif-row hover:bg-gray-50"></tr>
          
          <tr class="mat-row" *matNoDataRow>
            <td class="mat-cell text-center py-4 text-gray-500" colspan="6">{{ 'ADMIN.DISPUTES.NO_RESOLVED' | translate }}</td>
          </tr>
        </table>
      </div>
    </div>
  `
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
