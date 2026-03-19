import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const OrdersRoutes: Routes = [
  {
    path: 'checkout/:id',
    loadComponent: () => import('./checkout/checkout').then(m => m.CheckoutComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'checkout/:id/payment',
    loadComponent: () => import('./payment/payment').then(m => m.PaymentComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'my-orders',
    loadComponent: () => import('./my-orders/my-orders').then(m => m.MyOrdersComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'orders/:id',
    loadComponent: () => import('./order-details/order-details').then(m => m.OrderDetailsComponent),
    canActivate: [AuthGuard]
  }
];
