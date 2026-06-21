import { Routes } from '@angular/router';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { ProfileRoutes } from './features/profile/profile.routes';
import { CHAT_ROUTES } from './features/chat/chat.routes';
import { NOTIFICATIONS_ROUTES } from './features/notifications/notifications.routes';
import { NotFound } from './shared/components/not-found/not-found';
import { SUPPORT_ROUTES } from './features/support/support.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...ProfileRoutes,
  {
    path: 'support',
    children: SUPPORT_ROUTES
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
    redirectTo: '/support/tickets',
    pathMatch: 'full'
  },
  {
    path: '**',
    component: NotFound,
  },
];
