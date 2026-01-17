import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { ChartModule } from 'primeng/chart';
import { SkeletonModule } from 'primeng/skeleton';
import { TagModule } from 'primeng/tag';
import { KPIsClient, GlobalKPIsDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-kpi-dashboard',
    standalone: true,
    imports: [CommonModule, CardModule, ChartModule, SkeletonModule, TagModule],
    templateUrl: './kpi-dashboard.component.html',
    styleUrl: './kpi-dashboard.component.scss'
})
export class KpiDashboardComponent implements OnInit {
    private readonly kpiClient = inject(KPIsClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    kpiData = signal<GlobalKPIsDto | null>(null);
    revenueTrendData = signal<any>(null);
    orderTrendData = signal<any>(null);
    averageOrderValue = signal<number>(0);

    ngOnInit() {
        this.loadKpiData();
    }

    private loadKpiData() {
        this.kpiClient.getGlobalKPIs().subscribe({
            next: (data) => {
                this.kpiData.set(data);
                if (data.totalOrders && data.totalRevenue) {
                    this.averageOrderValue.set(data.totalRevenue / data.totalOrders);
                }
                this.prepareChartData(data);
                this.loading.set(false);
            },
            error: (err) => {
                this.toast.showError('Failed to load KPI data');
                this.loading.set(false);
            }
        });
    }

    private prepareChartData(data: GlobalKPIsDto) {
        if (!data.revenueTrend) return;

        this.revenueTrendData.set({
            labels: data.revenueTrend.map(t => t.month),
            datasets: [
                {
                    label: 'Revenue',
                    data: data.revenueTrend.map(t => t.revenue),
                    borderColor: '#42A5F5',
                    backgroundColor: 'rgba(66, 165, 245, 0.2)',
                    tension: 0.4,
                    fill: true
                }
            ]
        });

        if ((data as any).orderTrend) {
            this.orderTrendData.set({
                labels: ((data as any).orderTrend || []).map((t: any) => t.period),
                datasets: [
                    {
                        label: 'Orders',
                        data: ((data as any).orderTrend || []).map((t: any) => t.value),
                        borderColor: '#66BB6A',
                        backgroundColor: 'rgba(102, 187, 106, 0.2)',
                        tension: 0.4,
                        fill: true
                    }
                ]
            });
        }
    }

    get chartOptions(): any {
        return {
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: { display: false },
                y: { display: false }
            },
            maintainAspectRatio: false,
            responsive: true
        };
    }

    getInsightSeverity(type: string | undefined): 'info' | 'warn' | 'success' | 'danger' {
        switch (type?.toLowerCase()) {
            case 'warning': return 'warn';
            case 'success': return 'success';
            case 'critical': return 'danger';
            default: return 'info';
        }
    }
}
