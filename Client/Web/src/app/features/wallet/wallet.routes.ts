import { Route } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const WalletRoutes: Route[] = [
  {
    path: '',
    loadComponent: () => import('./components/wallet-dashboard.component').then(m => m.WalletDashboardComponent),
    canActivate: [AuthGuard],
  }
];
