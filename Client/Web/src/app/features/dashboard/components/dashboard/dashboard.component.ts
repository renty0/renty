import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TabsModule } from 'primeng/tabs';
import { KpiDashboardComponent } from '../kpi-dashboard/kpi-dashboard.component';
import { GapDashboardComponent } from '../gap-dashboard/gap-dashboard.component';
import { AnalyticsDashboardComponent } from '../analytics-dashboard/analytics-dashboard.component';
import { TranslateModule } from '@ngx-translate/core';

@Component({
    selector: 'app-dashboard',
    standalone: true,
    imports: [
        CommonModule,
        TabsModule,
        TranslateModule,
        KpiDashboardComponent,
        GapDashboardComponent,
        AnalyticsDashboardComponent
    ],
    templateUrl: './dashboard.component.html',
    styleUrl: './dashboard.component.scss'
})
export class DashboardComponent {
}
