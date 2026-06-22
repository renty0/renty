import { Routes } from '@angular/router';

export const ADMIN_ROUTES: Routes = [
  {
    path: 'disputes',
    children: [
      { path: 'open', loadComponent: () => import('./disputes/open-disputes/open-disputes.component').then(m => m.OpenDisputesComponent) },
      { path: 'resolved', loadComponent: () => import('./disputes/resolved-disputes/resolved-disputes.component').then(m => m.ResolvedDisputesComponent) },
      { path: 'financials', loadComponent: () => import('./disputes/financial-resolution/financial-resolution.component').then(m => m.FinancialResolutionComponent) },
      { path: '', redirectTo: 'open', pathMatch: 'full' }
    ]
  },
  {
    path: 'item-management',
    loadComponent: () => import('./item-management/item-management.component').then(m => m.ItemManagementComponent)
  },
  {
    path: 'id-verifications',
    loadComponent: () => import('./id-verification-requests/id-verification-requests.component').then(m => m.IdVerificationRequestsComponent)
  },
  {
    path: '',
    redirectTo: 'item-management',
    pathMatch: 'full'
  }
];
