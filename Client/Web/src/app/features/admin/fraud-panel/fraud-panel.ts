import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatCardModule } from '@angular/material/card';
import { rxResource } from '@angular/core/rxjs-interop';
import { AdminClient, IFraudLogDto } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { map } from 'rxjs';

@Component({
  selector: 'app-fraud-panel',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatChipsModule,
    MatProgressBarModule,
    MatPaginatorModule,
    MatCardModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './fraud-panel.html',
  styleUrl: './fraud-panel.scss'
})
export class FraudPanelComponent {
  private adminClient = inject(AdminClient);

  pageSize = signal(20);
  pageIndex = signal(0);

  fraudResource = rxResource({
    params: () => ({ page: this.pageIndex() + 1, limit: this.pageSize() }),
    stream: ({ params }) => this.adminClient.getFraudLogs(params.page, params.limit).pipe(
      map((response: any) => response?.data || { logs: [] as IFraudLogDto[], total: 0 })
    )
  });

  logs = computed<IFraudLogDto[]>(() => this.fraudResource.value()?.logs || []);
  totalLogs = computed(() => this.fraudResource.value()?.total || 0);
  isLoading = computed(() => this.fraudResource.isLoading());

  // Security Metrics
  highRiskCount = computed(() => this.logs().filter((l: IFraudLogDto) => (l.riskScore || 0) > 0.8).length);
  blockedCount = computed(() => this.logs().filter((l: IFraudLogDto) => l.decision?.toLowerCase() === 'blocked').length);
  flaggedCount = computed(() => this.logs().filter((l: IFraudLogDto) => l.decision?.toLowerCase() === 'flagged').length);

  displayedColumns: string[] = ['date', 'user', 'risk', 'decision', 'reason'];

  onPageChange(event: PageEvent): void {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
  }

  refresh(): void {
    this.fraudResource.reload();
  }

  getRiskColor(score: number | undefined): string {
    if (!score) return '#4caf50';
    if (score > 0.8) return '#f44336'; // Critical
    if (score > 0.5) return '#ff9800'; // Warning
    return '#4caf50'; // Safe
  }

  getDecisionVariant(decision: string | undefined): string {
    switch (decision?.toLowerCase()) {
      case 'blocked': return 'warn';
      case 'flagged': return 'accent';
      case 'allowed': return 'primary';
      default: return 'basic';
    }
  }
}
