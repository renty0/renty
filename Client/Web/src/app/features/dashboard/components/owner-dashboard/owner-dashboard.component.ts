import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { SkeletonModule } from 'primeng/skeleton';
import { DashboardClient, OwnerDashboardDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-owner-dashboard',
    imports: [CommonModule, CardModule, SkeletonModule],
    templateUrl: './owner-dashboard.component.html',
    styleUrls: ['./owner-dashboard.component.scss'] 
})
export class OwnerDashboardComponent implements OnInit {
    private readonly dashboardClient = inject(DashboardClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    dashboardData = signal<OwnerDashboardDto | null>(null);

    ngOnInit() {
        this.dashboardClient.getOwnerDashboard().subscribe({
            next: (data) => {
                this.dashboardData.set(data);
                this.loading.set(false);
            },
            error: () => {
                this.toast.showError('Failed to load dashboard data');
                this.loading.set(false);
            }
        });
    }
}
