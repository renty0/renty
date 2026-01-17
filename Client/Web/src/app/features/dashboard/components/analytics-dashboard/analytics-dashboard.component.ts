import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { ChartModule } from 'primeng/chart';
import { TableModule } from 'primeng/table';
import { TagModule } from 'primeng/tag';
import { AnalyticsClient, SalesTrendDto, CustomerDemographicsDto, InventoryStatsDto, ProductDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-analytics-dashboard',
    standalone: true,
    imports: [CommonModule, CardModule, ChartModule, TableModule, TagModule],
    templateUrl: './analytics-dashboard.component.html',
    styleUrl: './analytics-dashboard.component.scss'
})
export class AnalyticsDashboardComponent implements OnInit {
    private readonly analyticsClient = inject(AnalyticsClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    salesTrends = signal<SalesTrendDto[]>([]);
    demographics = signal<CustomerDemographicsDto | null>(null);
    inventory = signal<InventoryStatsDto | null>(null);
    topProducts = signal<any[]>([]);

    // Chart Data Signals
    salesChartData = signal<any>(null);
    genderChartData = signal<any>(null);
    incomeChartData = signal<any>(null);
    computedTotalRevenue = signal<number>(0);
    computedUtilization = signal<number>(0);

    ngOnInit() {
        this.loadAnalytics();
    }

    private loadAnalytics() {
        this.analyticsClient.getSalesTrend('monthly').subscribe({
            next: (data) => {
                this.salesTrends.set(data || []);
                this.prepareSalesChart(data || []);
            },
            error: () => this.toast.showError('Failed to load sales trends')
        });

        this.analyticsClient.getCustomerDemographics().subscribe({
            next: (data) => {
                this.demographics.set(data);
                this.prepareDemographicsCharts(data);
            },
            error: () => this.toast.showError('Failed to load demographics')
        });

        this.analyticsClient.getInventoryStats().subscribe({
            next: (data) => {
                this.inventory.set(data);
                let total = 0;
                if (data.revenueByCategory) {
                    total = data.revenueByCategory.reduce((acc: number, curr: any) => acc + (curr.revenue || 0), 0);
                    this.computedTotalRevenue.set(total);
                }

                // Calculate Top Category Revenue Share
                let share = 0;
                if (data.revenueByCategory && data.revenueByCategory.length > 0 && total > 0) {
                    const maxRev = Math.max(...data.revenueByCategory.map((c: any) => c.revenue || 0));
                    share = (maxRev / total) * 100;
                }
                this.computedUtilization.set(share);
            },
            error: () => this.toast.showError('Failed to load inventory stats')
        });

        this.analyticsClient.getProductPerformance(10).subscribe({
            next: (data: any) => this.topProducts.set(data.topProducts || []),
            error: () => this.toast.showError('Failed to load top products'),
            complete: () => this.loading.set(false)
        });
    }

    private prepareSalesChart(trends: SalesTrendDto[]) {
        this.salesChartData.set({
            labels: trends.map(t => t.period),
            datasets: [
                {
                    label: 'Revenue',
                    data: trends.map(t => t.totalRevenue),
                    borderColor: '#42A5F5',
                    fill: false,
                    tension: 0.4
                }
            ]
        });
    }

    private prepareDemographicsCharts(data: CustomerDemographicsDto) {
        if (data.genderBreakdown) {
            this.genderChartData.set({
                labels: data.genderBreakdown.map(x => x.category),
                datasets: [{
                    data: data.genderBreakdown.map(x => x.count),
                    backgroundColor: ['#42A5F5', '#EC407A', '#AB47BC']
                }]
            });
        }

        // Using Occupation Breakdown instead of Income as Income is not available in DTO
        if (data.occupationBreakdown) {
            this.incomeChartData.set({
                labels: data.occupationBreakdown.map(x => x.category),
                datasets: [{
                    data: data.occupationBreakdown.map(x => x.count),
                    backgroundColor: ['#66BB6A', '#FFA726', '#26A69A', '#78909C']
                }]
            });
        }
    }

    get lineOptions(): any {
        return {
            maintainAspectRatio: false,
            plugins: { legend: { position: 'top' } },
            scales: { y: { beginAtZero: true } }
        };
    }

    get pieOptions(): any {
        return {
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom' } }
        };
    }
}
