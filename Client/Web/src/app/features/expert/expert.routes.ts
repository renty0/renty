import { Routes } from '@angular/router';
import { AuthGuard } from '../../core/guards/auth.guard';
// We need an ExpertGuard or reuse AuthGuard + role check
import { ExpertAssignedComponent } from './expert-assigned/expert-assigned';
import { VerificationHistoryComponent } from './verification-history/verification-history';

export const EXPERT_ROUTES: Routes = [
  {
    path: '',
    children: [
      {
        path: 'assigned',
        component: ExpertAssignedComponent,
        canActivate: [AuthGuard],
        data: { role: 'Expert' }, // AuthGuard should handle this if implemented, otherwise just AuthGuard
      },
      {
        path: 'verify/:id', // The id is the verificationId in our UI, but the API needs ItemId?
        component: VerificationHistoryComponent,
        canActivate: [AuthGuard],
        data: { role: 'Expert' },
      },
      {
        path: '',
        redirectTo: 'assigned',
        pathMatch: 'full',
      },
    ],
  },
];
