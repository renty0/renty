import { Routes } from '@angular/router';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { ProfileRoutes } from './features/profile/profile.routes';
import { CHAT_ROUTES } from './features/chat/chat.routes';
import { NOTIFICATIONS_ROUTES } from './features/notifications/notifications.routes';
import { NotFound } from './shared/components/not-found/not-found';
import { ADMIN_ROUTES } from './features/admin/admin.routes';
import { AuthGuard } from './core/guards/auth.guard';
import { AdminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  ...AuthRoutes,
  ...ProfileRoutes,
  {
    path: 'admin',
    children: ADMIN_ROUTES,
    canActivate: [AuthGuard, AdminGuard]
  },
  {
    path: 'chats',
    children: CHAT_ROUTES
  },
  {
    path: 'notifications',
    children: NOTIFICATIONS_ROUTES
  },
  {
    path: '',
    redirectTo: '/admin/disputes/open',
    pathMatch: 'full'
  },
  {
    path: '**',
    component: NotFound,
  },
];
