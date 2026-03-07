import { Routes } from '@angular/router';
import { NotFound } from './shared/components/not-found/not-found';
import { AuthGuard } from './core/guards/auth.guard';
import { AdminGuard } from './core/guards/admin.guard';
import { AuthRoutes } from './features/auth/routes/auth.routes';
import { HomeComponent } from './features/home/components/home/home.component';
import { CategoriesRoutes } from './features/categories/categories.routes';
import { SubcategoriesRoutes } from './features/subcategories/subcategories.routes';
import { BrandsRoutes } from './features/brands/brands.routes';
import { ProductDetailsComponent } from './features/marketplace/product-details/product-details.component';
import { MarketplaceComponent } from './features/marketplace/marketplace.component';
import { ItemsRoutes } from './features/items/items.routes';

export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  ...SubcategoriesRoutes,
  ...BrandsRoutes,
  ...ItemsRoutes,
  {
    path: 'marketplace/product/:id',
    component: ProductDetailsComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'marketplace',
    component: MarketplaceComponent,
    canActivate: [AuthGuard]
  },
  // {
  //   path: 'profile',
  //   component: ProfileComponent,
  //   canActivate: [AuthGuard]
  // },
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: '**',
    component: NotFound,
  },
];
