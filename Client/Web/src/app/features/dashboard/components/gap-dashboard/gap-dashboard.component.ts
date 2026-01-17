import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { ChartModule } from 'primeng/chart';
import { SkeletonModule } from 'primeng/skeleton';
import { TableModule } from 'primeng/table';
import { TagModule } from 'primeng/tag';
import { Gap_AnalysisClient, GapAnalysisSummaryDto, DeadStockDto, GapActionPlanDto, KPIsClient, GlobalKPIsDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-gap-dashboard',
    standalone: true,
    imports: [CommonModule, CardModule, ChartModule, SkeletonModule, TableModule, TagModule],
    templateUrl: './gap-dashboard.component.html',
    styleUrl: './gap-dashboard.component.scss'
})
export class GapDashboardComponent implements OnInit {
    private readonly gapClient = inject(Gap_AnalysisClient);
    private readonly kpiClient = inject(KPIsClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    summary = signal<GapAnalysisSummaryDto | null>(null);
    gapChartData = signal<any>(null);
    territoryHeatmapData = signal<any>(null);
    deadStock = signal<DeadStockDto[]>([]);
    actions = signal<string[]>([]);
    kpiData = signal<GlobalKPIsDto | null>(null);

    ngOnInit() {
        this.loadGapData();
    }

    private loadGapData() {
        this.kpiClient.getGlobalKPIs().subscribe({
            next: (data) => this.kpiData.set(data),
            error: () => this.toast.showError('Failed to load KPI data')
        });

        this.gapClient.getGapAnalysisSummary().subscribe({
            next: (data) => {
                this.summary.set(data);
                this.loading.set(false);
            },
            error: () => this.toast.showError('Failed to load gap summary')
        });

        this.gapClient.getCategoryGapAnalysis().subscribe({
            next: (data) => this.prepareGapChart(data || []),
            error: () => this.toast.showError('Failed to load category analysis')
        });

        this.gapClient.getTerritoryGapAnalysis().subscribe({
            next: (data) => this.prepareHeatmap(data || []),
            error: () => this.toast.showError('Failed to load territory analysis')
        });

        this.gapClient.getDeadStockAnalysis().subscribe({
            next: (data) => this.deadStock.set(data || []),
            error: () => this.toast.showError('Failed to load dead stock')
        });

        this.gapClient.getGapAnalysisActionPlan().subscribe({
            next: (data) => {
                const allActions = (data || []).flatMap(d => [
                    ...(d.operationalActions || []),
                    ...(d.strategicActions || []),
                    ...(d.platformActions || []),
                    ...(d.userEngagementActions || [])
                ]);
                this.actions.set([...new Set(allActions)]);
            },
            error: () => this.toast.showError('Failed to load actions')
        });
    }

    private prepareGapChart(gaps: any[]) {
        this.gapChartData.set({
            labels: gaps.map(g => g.categoryName),
            datasets: [
                {
                    label: 'Demand (Orders)',
                    backgroundColor: '#42A5F5',
                    data: gaps.map(g => g.uniqueOrders ?? g.totalQuantitySold ?? 0)
                },
                {
                    label: 'Supply (Unique Items)',
                    backgroundColor: '#66BB6A',
                    data: gaps.map(g => g.uniqueProducts ?? g.supplyCount ?? 0)
                }
            ]
        });
    }

    private prepareHeatmap(data: any[]) {
        // Group by region and average the gap score
        const regionalGroups = data.reduce((acc: any, curr: any) => {
            const region = curr.region || 'Unknown';
            if (!acc[region]) {
                acc[region] = { sum: 0, count: 0 };
            }
            acc[region].sum += curr.gapScore || 0;
            acc[region].count++;
            return acc;
        }, {});

        const regions = Object.keys(regionalGroups);
        let avgGapScores = regions.map(r => regionalGroups[r].sum / regionalGroups[r].count);

        // If data is missing gapScore (as in the provided JSON), use uniqueOrders and normalize it
        if (avgGapScores.every(v => v === 0)) {
            const volumes = regions.map(r => data.filter(d => (d.region || 'Unknown') === r).reduce((s, c) => s + (c.uniqueOrders || 0), 0));
            const maxVol = Math.max(...volumes) || 1;
            avgGapScores = volumes.map(v => v / maxVol);
        }

        this.territoryHeatmapData.set({
            labels: regions,
            datasets: [{
                label: 'Avg Regional Demand Score',
                data: avgGapScores,
                backgroundColor: 'rgba(66, 165, 245, 0.2)',
                borderColor: '#42A5F5',
                pointBackgroundColor: '#42A5F5'
            }]
        });
    }

    get barChartOptions(): any {
        return {
            maintainAspectRatio: false,
            aspectRatio: 0.8,
            plugins: {
                legend: { position: 'bottom' }
            },
            scales: {
                x: { stacked: false },
                y: { beginAtZero: true }
            }
        };
    }

    get radarOptions(): any {
        return {
            plugins: {
                legend: { position: 'bottom' }
            },
            scales: {
                r: {
                    min: 0,
                    suggestedMax: 1,
                    ticks: { stepSize: 0.2 }
                }
            }
        };
    }
}
