import { Component, inject, OnInit, signal } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { AdminClient, IKpiSnapshotDto } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';

@Component({
  selector: 'app-sa-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule,
    MatProgressBarModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './sa-dashboard.html',
  styleUrl: './sa-dashboard.scss'
})
export class SaDashboardComponent implements OnInit {
  private adminClient = inject(AdminClient);

  kpi = signal<IKpiSnapshotDto | null>(null);
  isLoading = signal(true);
  error = signal<string | null>(null);

  // Staff overview counts (from user list API, filtered by role)
  staffCounts = signal({ admins: 0, support: 0, experts: 0 });
  staffLoading = signal(true);

  // Critical alerts (could come from a future API, mock for now)
  alerts = signal<{ severity: string; icon: string; text: string; time: string }[]>([]);

  ngOnInit(): void {
    this.loadKpi();
    this.loadStaffOverview();
    this.loadAlerts();
  }

  loadKpi(): void {
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

  loadStaffOverview(): void {
    this.staffLoading.set(true);
    // Load all users and count by role
    this.adminClient.getAdminUsers(1, 200, undefined)
      .pipe(finalize(() => this.staffLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (!response.error && response.data) {
            const users = response.data.users || [];
            this.staffCounts.set({
              admins: users.filter(u => u.roles?.some(r => r.toLowerCase() === 'admin')).length,
              support: users.filter(u => u.roles?.some(r => r.toLowerCase() === 'support')).length,
              experts: users.filter(u => u.roles?.some(r => r.toLowerCase() === 'expert')).length,
            });
          }
        },
        error: () => console.error('Failed to load staff overview')
      });
  }

  loadAlerts(): void {
    // Future: fetch from API. For now, generate from KPI data after load.
    this.alerts.set([]);
  }
}
