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
        path: 'disputes',
        children: [
          { path: 'open', loadComponent: () => import('./disputes/open-disputes/open-disputes.component').then(m => m.OpenDisputesComponent) },
          { path: 'resolved', loadComponent: () => import('./disputes/resolved-disputes/resolved-disputes.component').then(m => m.ResolvedDisputesComponent) },
          { path: 'financials', loadComponent: () => import('./disputes/financial-resolution/financial-resolution.component').then(m => m.FinancialResolutionComponent) },
          { path: '', redirectTo: 'open', pathMatch: 'full' }
        ],
        data: { permission: PermissionType.Disputes_View }
      },
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
        path: 'id-verifications',
        loadComponent: () => import('./id-verification-requests/id-verification-requests.component').then(m => m.IdVerificationRequestsComponent),
        data: { permission: PermissionType.Users_View }
      },
      {
        path: 'rental-financials/:id',
        loadComponent: () => import('./rental-financial-breakdown/rental-financial-breakdown.component').then(m => m.RentalFinancialBreakdownComponent),
        data: { permission: PermissionType.Dashboards_View }
      },
      {
        path: 'disputes/details/:id',
        loadComponent: () => import('./disputes/dispute-details/dispute-details.component').then(m => m.DisputeDetailsComponent),
        data: { permission: PermissionType.Disputes_View }
      },
      {
        path: '',
        redirectTo: 'disputes/open',
        pathMatch: 'full'
      }
    ]
  }
];
