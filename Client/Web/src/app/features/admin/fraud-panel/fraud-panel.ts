import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { AdminClient, IFraudLogDto } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatProgressBar } from '@angular/material/progress-bar';

@Component({
  selector: 'app-fraud-panel',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatChipsModule,
    MatProgressBar,
    MatPaginatorModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './fraud-panel.html',
  styleUrl: './fraud-panel.scss'
})
export class FraudPanelComponent implements OnInit {
  private adminClient = inject(AdminClient);

  logs = signal<IFraudLogDto[]>([]);
  totalLogs = signal(0);
  pageSize = signal(20);
  pageIndex = signal(0);
  isLoading = signal(true);
  error = signal<string | null>(null);

  displayedColumns: string[] = ['date', 'user', 'risk', 'decision', 'reason'];

  ngOnInit(): void {
    this.loadFraudLogs();
  }

  loadFraudLogs(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getFraudLogs(this.pageIndex() + 1, this.pageSize()).subscribe({
      next: (response: any) => {
        if (response && response.data) {
          this.logs.set(response.data.logs || []);
          this.totalLogs.set(response.data.total || 0);
        } else {
          this.error.set(response?.error || 'Failed to load fraud logs');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.error.set('An error occurred while fetching fraud logs');
        this.isLoading.set(false);
        console.error('Fraud Logs Error:', err);
      }
    });
  }

  onPageChange(event: PageEvent): void {
    this.pageIndex.set(event.pageIndex);
    this.pageSize.set(event.pageSize);
    this.loadFraudLogs();
  }

  getRiskColor(score: number): string {
    if (score > 0.8) return '#f44336';
    if (score > 0.5) return '#ff9800';
    return '#4caf50';
  }

  getDecisionColor(decision: string): string {
    switch (decision?.toLowerCase()) {
      case 'blocked': return 'warn';
      case 'flagged': return 'accent';
      case 'allowed': return 'primary';
      default: return '';
    }
  }
}
