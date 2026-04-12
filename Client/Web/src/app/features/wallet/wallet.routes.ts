import { Route } from '@angular/router';
import { LoginGuard } from '../../core/guards/logged.guard';

export const WalletRoutes: Route[] = [
  {
    path: '',
    loadComponent: () => import('./components/wallet-dashboard.component').then(m => m.WalletDashboardComponent),
    canActivate: [LoginGuard],
  }
];
