import { Routes } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AdminDashboardComponent } from './components/admin-dashboard/admin-dashboard.component';

export const DashboardRoutes: Routes = [
    {
        path: 'dashboard',
        component: AdminDashboardComponent,
    }
];
