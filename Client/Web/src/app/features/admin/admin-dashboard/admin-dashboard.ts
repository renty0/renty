import { Component, inject, OnInit, signal } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { AdminClient, IKpiSnapshotDto } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule,
    MatProgressBarModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './admin-dashboard.html',
  styleUrl: './admin-dashboard.scss'
})
export class AdminDashboardComponent implements OnInit {
  private adminClient = inject(AdminClient);

  kpi = signal<IKpiSnapshotDto | null>(null);
  isLoading = signal(true);
  error = signal<string | null>(null);

  ngOnInit(): void {
    this.loadLatestKpi();
  }

  loadLatestKpi(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getAdminLatestKpi()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (!response.error && response.data) {
            this.kpi.set(response.data);
          } else {
            this.error.set(response.messages?.[0] || 'Failed to load KPI data');
          }
        },
        error: (err) => {
          this.error.set('An error occurred while fetching dashboard data');
          console.error('KPI Load Error:', err);
        }
      });
  }
}
