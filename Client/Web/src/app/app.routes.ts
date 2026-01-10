import { Routes } from '@angular/router';
import { NotFound } from './shared/components/not-found/not-found';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { HomeComponent } from './features/home/components/home/home.component';
import { CategoriesRoutes } from './features/categories/categories.routes';
import { SubcategoriesRoutes } from './features/subcategories/subcategories.routes';
import { ProductsRoutes } from './features/products/products.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  ...SubcategoriesRoutes,
  ...ProductsRoutes,
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: '**',
    component: NotFound,
  },
];
