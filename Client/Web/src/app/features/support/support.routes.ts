import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const SUPPORT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    children: [
      {
        path: '',
        loadComponent: () => import('./ticket-list/ticket-list').then(m => m.TicketListComponent)
      },
      {
        path: 'new',
        loadComponent: () => import('./create-ticket/create-ticket').then(m => m.CreateTicketComponent)
      },
      {
        path: ':id',
        loadComponent: () => import('./ticket-details/ticket-details').then(m => m.TicketDetailsComponent)
      }
    ]
  }
];
