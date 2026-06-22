import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';

import { TicketList } from './ticket-list/ticket-list';
import { TicketDetail } from './ticket-detail/ticket-detail';

export const SUPPORT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [AuthGuard],
    children: [

      {
        path: 'tickets',
        component: TicketList
      },
      {
        path: 'tickets/:id',
        component: TicketDetail
      },
      {
        path: ':id',
        component: TicketDetail
      },
      {
        path: '',
        redirectTo: 'tickets',
        pathMatch: 'full'
      }
    ]
  }
];
