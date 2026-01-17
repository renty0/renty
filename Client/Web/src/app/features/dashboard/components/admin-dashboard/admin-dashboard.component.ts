import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { ChartModule } from 'primeng/chart';
import { SkeletonModule } from 'primeng/skeleton';
import { TableModule } from 'primeng/table';
import { TagModule } from 'primeng/tag';
import { ButtonModule } from 'primeng/button';
import { TimelineModule } from 'primeng/timeline';
import { DashboardClient, AdminDashboardDto } from '../../../../core/api/api-client';
import { ToastService } from '../../../../shared/services/toast.service';

@Component({
    selector: 'app-admin-dashboard',
    imports: [CommonModule, CardModule, ChartModule, SkeletonModule, TableModule, TagModule, ButtonModule, TimelineModule],
    templateUrl: './admin-dashboard.component.html',
    styleUrl: './admin-dashboard.component.scss'
})
export class AdminDashboardComponent implements OnInit {
    private readonly dashboardClient = inject(DashboardClient);
    private readonly toast = inject(ToastService);

    loading = signal(true);
    dashboardData = signal<AdminDashboardDto | null>(null);
    salesTrendData = signal<any>(null);
    customerDemographicsData = signal<any>(null);
    revenueByCategory = signal<any>(null);
    monthlyComparison = signal<any>(null);
    userGrowth = signal<any>(null);
    rentalStatus = signal<any>(null);
    hourlyActivity = signal<any>(null);
    topLocations = signal<any>(null);
    topProducts = signal<any[]>([]);
    recentTransactions = signal<any[]>([]);

    ngOnInit() {
        this.loadDashboardData();
        this.loadMockChartData();
    }

    private loadDashboardData() {
        this.dashboardClient.getAdminDashboard().subscribe({
            next: (data) => {
                this.dashboardData.set(data);
                this.loading.set(false);
            },
            error: (err) => {
                this.toast.showError('Failed to load dashboard data');
                this.loading.set(false);
            }
        });
    }

    private loadMockChartData() {
        // Sales Trend Data
        this.salesTrendData.set({
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [
                {
                    label: 'Revenue',
                    data: [12000, 19000, 15000, 25000, 22000, 30000],
                    borderColor: '#42A5F5',
                    backgroundColor: 'rgba(66, 165, 245, 0.2)',
                    tension: 0.4,
                    fill: true,
                    yAxisID: 'y'
                },
                {
                    label: 'Orders',
                    data: [65, 95, 80, 120, 110, 140],
                    borderColor: '#66BB6A',
                    backgroundColor: 'rgba(102, 187, 106, 0.2)',
                    tension: 0.4,
                    fill: true,
                    yAxisID: 'y1'
                }
            ]
        });

        // Customer Demographics Data
        this.customerDemographicsData.set({
            labels: ['Male', 'Female', 'Other'],
            datasets: [{
                data: [450, 380, 70],
                backgroundColor: ['#42A5F5', '#EC407A', '#AB47BC'],
                hoverBackgroundColor: ['#64B5F6', '#F06292', '#BA68C8']
            }]
        });

        // Revenue by Category Data
        this.revenueByCategory.set({
            labels: ['Electronics', 'Furniture', 'Appliances', 'Tools', 'Sports'],
            datasets: [{
                label: 'Revenue',
                data: [45000, 32000, 28000, 18000, 15000],
                backgroundColor: '#66BB6A',
                borderColor: '#4CAF50',
                borderWidth: 1
            }]
        });

        // Monthly Comparison (Current vs Previous Year)
        this.monthlyComparison.set({
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [
                {
                    label: '2026',
                    data: [30000, 35000, 32000, 40000, 38000, 45000],
                    backgroundColor: 'rgba(66, 165, 245, 0.7)',
                    borderColor: '#42A5F5',
                    borderWidth: 1
                },
                {
                    label: '2025',
                    data: [25000, 28000, 27000, 32000, 30000, 35000],
                    backgroundColor: 'rgba(156, 39, 176, 0.7)',
                    borderColor: '#9C27B0',
                    borderWidth: 1
                }
            ]
        });

        // User Growth Over Time
        this.userGrowth.set({
            labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
            datasets: [{
                label: 'New Users',
                data: [45, 62, 58, 73],
                borderColor: '#FF9800',
                backgroundColor: 'rgba(255, 152, 0, 0.2)',
                tension: 0.4,
                fill: true
            }]
        });

        // Rental Status Distribution
        this.rentalStatus.set({
            labels: ['Active', 'Pending', 'Completed', 'Cancelled'],
            datasets: [{
                data: [120, 45, 380, 25],
                backgroundColor: ['#4CAF50', '#FFC107', '#2196F3', '#F44336'],
                hoverBackgroundColor: ['#66BB6A', '#FFD54F', '#42A5F5', '#EF5350']
            }]
        });

        // Hourly Activity
        this.hourlyActivity.set({
            labels: ['12am', '3am', '6am', '9am', '12pm', '3pm', '6pm', '9pm'],
            datasets: [{
                label: 'Rentals',
                data: [5, 3, 8, 25, 45, 60, 55, 30],
                backgroundColor: 'rgba(103, 58, 183, 0.7)',
                borderColor: '#673AB7',
                borderWidth: 1
            }]
        });

        // Top Locations
        this.topLocations.set({
            labels: ['Cairo', 'Alexandria', 'Giza', 'Sharm El-Sheikh', 'Hurghada'],
            datasets: [{
                label: 'Rentals',
                data: [320, 180, 150, 90, 60],
                backgroundColor: [
                    'rgba(244, 67, 54, 0.7)',
                    'rgba(33, 150, 243, 0.7)',
                    'rgba(76, 175, 80, 0.7)',
                    'rgba(255, 193, 7, 0.7)',
                    'rgba(156, 39, 176, 0.7)'
                ],
                borderWidth: 0
            }]
        });

        // Top Products Table Data
        this.topProducts.set([
            { name: 'MacBook Pro', category: 'Electronics', rentals: 145, revenue: 28500, trend: 'up' },
            { name: 'Office Desk', category: 'Furniture', rentals: 98, revenue: 19600, trend: 'up' },
            { name: 'Camera Kit', category: 'Electronics', rentals: 87, revenue: 17400, trend: 'down' },
            { name: 'Gaming Console', category: 'Electronics', rentals: 76, revenue: 15200, trend: 'up' },
            { name: 'Ergonomic Chair', category: 'Furniture', rentals: 65, revenue: 13000, trend: 'stable' }
        ]);

        // Recent Transactions
        this.recentTransactions.set([
            { id: '#12345', customer: 'Ahmed Hassan', item: 'MacBook Pro', amount: 1200, status: 'completed', time: '2 hours ago' },
            { id: '#12344', customer: 'Sara Mohamed', item: 'Camera Kit', amount: 800, status: 'active', time: '4 hours ago' },
            { id: '#12343', customer: 'Omar Ali', item: 'Office Desk', amount: 450, status: 'pending', time: '6 hours ago' },
            { id: '#12342', customer: 'Fatma Ibrahim', item: 'Gaming Console', amount: 650, status: 'completed', time: '8 hours ago' },
            { id: '#12341', customer: 'Khaled Youssef', item: 'Ergonomic Chair', amount: 380, status: 'active', time: '10 hours ago' }
        ]);
    }

    get chartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'Revenue ($)'
                    }
                },
                y1: {
                    beginAtZero: true,
                    position: 'right',
                    title: {
                        display: true,
                        text: 'Orders'
                    },
                    grid: {
                        drawOnChartArea: false
                    }
                }
            }
        };
    }

    get pieChartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        };
    }

    get barChartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Revenue ($)'
                    }
                }
            }
        };
    }

    get comparisonChartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Revenue ($)'
                    }
                }
            }
        };
    }

    get lineChartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Users'
                    }
                }
            }
        };
    }

    get polarChartOptions(): any {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right'
                }
            }
        };
    }

    getTrendIcon(trend: string): string {
        switch (trend) {
            case 'up': return 'pi-arrow-up';
            case 'down': return 'pi-arrow-down';
            default: return 'pi-minus';
        }
    }

    getTrendSeverity(trend: string): 'success' | 'danger' | 'info' {
        switch (trend) {
            case 'up': return 'success';
            case 'down': return 'danger';
            default: return 'info';
        }
    }

    getStatusSeverity(status: string): 'success' | 'warn' | 'info' {
        switch (status) {
            case 'completed': return 'success';
            case 'pending': return 'warn';
            default: return 'info';
        }
    }
}
