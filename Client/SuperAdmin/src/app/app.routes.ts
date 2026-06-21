import { Routes } from '@angular/router';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { CategoriesRoutes } from './features/categories/categories.routes';
import { SubcategoriesRoutes } from './features/subcategories/subcategories.routes';
import { BrandsRoutes } from './features/brands/brands.routes';
import { ADMIN_ROUTES } from './features/admin/admin.routes';
import { SUPER_ADMIN_ROUTES } from './features/super-admin/super-admin.routes';
import { NotFound } from './shared/components/not-found/not-found';
import { ProfileRoutes } from './features/profile/profile.routes';
import { CHAT_ROUTES } from './features/chat/chat.routes';
import { NOTIFICATIONS_ROUTES } from './features/notifications/notifications.routes';
import { ItemsRoutes } from './features/items/items.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  ...SubcategoriesRoutes,
  ...BrandsRoutes,
  ...ProfileRoutes,
  ...ItemsRoutes,
  {
    path: 'admin',
    children: ADMIN_ROUTES
  },
  {
    path: 'super-admin',
    children: SUPER_ADMIN_ROUTES
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
    redirectTo: '/super-admin/dashboard',
    pathMatch: 'full'
  },
  {
    path: '**',
    component: NotFound,
  },
];
