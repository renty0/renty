import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

export const SUPPORT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    children: [
      {
        path: '',
        redirectTo: 'tickets',
        pathMatch: 'full'
      },
      {
        path: 'tickets',
        loadComponent: () => import('./ticket-list/ticket-list').then(m => m.TicketListComponent)
      },
      {
        path: 'tickets/:id',
        loadComponent: () => import('./ticket-details/ticket-details').then(m => m.TicketDetailsComponent)
      },
      {
        path: 'new',
        loadComponent: () => import('./create-ticket/create-ticket').then(m => m.CreateTicketComponent)
      },
      {
        path: 'agent',
        loadComponent: () => import('./agent-dashboard/agent-dashboard.component').then(m => m.AgentDashboardComponent)
      }
    ]
  }
];
