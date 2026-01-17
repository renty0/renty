import { Routes } from '@angular/router';
import { NotFound } from './shared/components/not-found/not-found';
import { AuthGuard } from './core/guards/auth.guard';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { HomeComponent } from './features/home/components/home/home.component';
import { CategoriesRoutes } from './features/categories/categories.routes';
import { SubcategoriesRoutes } from './features/subcategories/subcategories.routes';
import { ProductsRoutes } from './features/products/products.routes';
import { DashboardRoutes } from './features/dashboard/dashboard.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  ...SubcategoriesRoutes,
  ...ProductsRoutes,
  ...DashboardRoutes,
  {
    path: 'profile',
    loadComponent: () => import('./features/profile/profile.component').then(m => m.ProfileComponent),
    canActivate: [AuthGuard]
  },
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: '**',
    component: NotFound,
  },
];
