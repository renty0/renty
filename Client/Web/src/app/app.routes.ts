import { Routes } from '@angular/router';
import { NotFound } from './shared/components/not-found/not-found';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { HomeComponent } from './features/home/components/home/home.component';
import { CategoriesRoutes } from './features/categories/categories.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: '**',
    component: NotFound,
  },
];
