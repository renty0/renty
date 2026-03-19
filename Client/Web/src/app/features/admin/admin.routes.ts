import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
import { AdminGuard } from '../../core/guards/admin.guard';

export const ADMIN_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard, AdminGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./admin-dashboard/admin-dashboard').then(m => m.AdminDashboardComponent)
      },
      {
        path: 'gap-analysis',
        loadComponent: () => import('./gap-analysis/gap-analysis').then(m => m.GapAnalysisComponent)
      },
      {
        path: 'fraud',
        loadComponent: () => import('./fraud-panel/fraud-panel').then(m => m.FraudPanelComponent)
      },
      {
        path: 'users',
        loadComponent: () => import('./user-management/user-management').then(m => m.UserManagementComponent)
      },
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full'
      }
    ]
  }
];
