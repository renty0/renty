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
import { SearchResultsComponent } from './features/search-results/search-results.component';
import { ItemsRoutes } from './features/items/items.routes';
import { FavoritesComponent } from './features/favorites/favorites';
import { OrdersRoutes } from './features/orders/orders.routes';
import { CHAT_ROUTES } from './features/chat/chat.routes';
import { NOTIFICATIONS_ROUTES } from './features/notifications/notifications.routes';
import { SUPPORT_ROUTES } from './features/support/support.routes';
import { EXPERT_ROUTES } from './features/expert/expert.routes';
import { ADMIN_ROUTES } from './features/admin/admin.routes';
import { SUPER_ADMIN_ROUTES } from './features/super-admin/super-admin.routes';
import { WalletRoutes } from './features/wallet/wallet.routes';
import { ProfileRoutes } from './features/profile/profile.routes';


export const routes: Routes = [
  ...AuthRoutes,
  ...CategoriesRoutes,
  ...SubcategoriesRoutes,
  ...BrandsRoutes,
  ...ItemsRoutes,
  ...OrdersRoutes,
  ...ProfileRoutes,
  {
    path: 'user-profile/:id',
    loadComponent: () => import('./features/public-profile/public-profile').then(m => m.PublicProfileComponent)
  },
  {
    path: 'wallet',
    children: WalletRoutes
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
    path: 'support',
    children: SUPPORT_ROUTES
  },
  {
    path: 'expert',
    children: EXPERT_ROUTES
  },
  {
    path: 'admin',
    children: ADMIN_ROUTES
  },
  {
    path: 'super-admin',
    children: SUPER_ADMIN_ROUTES
  },
  {
    path: 'my-rentals',
    loadComponent: () => import('./features/rentals/my-rentals/my-rentals').then(m => m.MyRentalsComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'rentals/:id',
    loadComponent: () => import('./features/rentals/rental-details/rental-details').then(m => m.RentalDetailsComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'search',
    component: SearchResultsComponent,
    canActivate: [AuthGuard]
  },
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
  {
    path: 'favorites',
    component: FavoritesComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'about',
    loadComponent: () => import('./features/public/about-us/about-us.component').then(m => m.AboutUsComponent)
  },
  {
    path: 'contact',
    loadComponent: () => import('./features/public/contact-us/contact-us.component').then(m => m.ContactUsComponent)
  },
  {
    path: 'terms',
    loadComponent: () => import('./features/public/terms-page/terms-page.component').then(m => m.TermsPageComponent)
  },
  {
    path: 'privacy',
    loadComponent: () => import('./features/public/privacy-page/privacy-page.component').then(m => m.PrivacyPageComponent)
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
