import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { SkeletonModule } from 'primeng/skeleton';
import { DashboardClient, RenterDashboardDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-renter-dashboard',
    imports: [CommonModule, CardModule, SkeletonModule],
    templateUrl: './renter-dashboard.component.html',
    styleUrls: ['./renter-dashboard.component.scss']
})
export class RenterDashboardComponent implements OnInit {
    private readonly dashboardClient = inject(DashboardClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    dashboardData = signal<RenterDashboardDto | null>(null);

    ngOnInit() {
        this.dashboardClient.getRenterDashboard().subscribe({
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
