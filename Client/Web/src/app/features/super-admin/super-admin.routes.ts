import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
import { AdminGuard } from '../../core/guards/admin.guard';
import { PermissionType } from '../../core/constants/permissions';

export const SUPER_ADMIN_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard, AdminGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./sa-dashboard/sa-dashboard').then(m => m.SaDashboardComponent),
        data: { permission: PermissionType.Dashboards_View }
      },
      {
        path: 'staff',
        loadComponent: () => import('./staff-management/staff-management').then(m => m.StaffManagementComponent),
        data: { permission: PermissionType.Staff_View }
      },
      {
        path: 'overrides',
        loadComponent: () => import('./overrides/overrides').then(m => m.OverridesComponent),
        data: { permission: PermissionType.Overrides_Execute }
      },
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full'
      }
    ]
  }
];
