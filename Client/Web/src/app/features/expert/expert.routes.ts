import { Routes } from '@angular/router';
import { ExpertGuard } from '../../core/guards/expert.guard';
import { ExpertAssignedComponent } from './expert-assigned/expert-assigned';
import { VerificationHistoryComponent } from './verification-history/verification-history';

export const EXPERT_ROUTES: Routes = [
  {
    path: '',
    canActivate: [ExpertGuard],
    children: [
      {
        path: 'assigned',
        component: ExpertAssignedComponent,
      },
      {
        path: 'verify/:id', // Note: This :id is now ItemId as fixed in routing
        component: VerificationHistoryComponent,
      },
      {
        path: '',
        redirectTo: 'assigned',
        pathMatch: 'full',
      },
    ],
  },
];
