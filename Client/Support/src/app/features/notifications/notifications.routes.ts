import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const NOTIFICATIONS_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    loadComponent: () => import('./notification-list/notification-list').then(m => m.NotificationListComponent)
  }
];
