import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
import { AdminGuard } from '../../core/guards/admin.guard';
import { PermissionType } from '../../core/constants/permissions';

export const ADMIN_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard, AdminGuard],
    children: [

      {
        path: 'gap-analysis',
        loadComponent: () => import('./gap-analysis/gap-analysis').then(m => m.GapAnalysisComponent),
        data: { permission: PermissionType.Dashboards_View }
      },
      {
        path: 'fraud',
        loadComponent: () => import('./fraud-panel/fraud-panel').then(m => m.FraudPanelComponent),
        data: { permission: PermissionType.Dashboards_View }
      },
      {
        path: 'users',
        loadComponent: () => import('./user-management/user-management').then(m => m.UserManagementComponent),
        data: { permission: PermissionType.Users_View }
      },
      {
        path: 'roles',
        loadComponent: () => import('./role-management/role-management').then(m => m.RoleManagementComponent),
        data: { permission: PermissionType.Roles_View }
      },
      {
        path: 'item-management',
        loadComponent: () => import('./item-management/item-management.component').then(m => m.ItemManagementComponent),
        data: { permission: PermissionType.Items_View }
      },
      {
        path: 'settings',
        loadComponent: () => import('./system-settings/system-settings.component').then(m => m.SystemSettingsComponent),
        data: { permission: PermissionType.Settings_View }
      },
      {
        path: '',
        redirectTo: 'gap-analysis',
        pathMatch: 'full'
      }
    ]
  }
];
