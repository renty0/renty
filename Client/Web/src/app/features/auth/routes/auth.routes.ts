import { Route } from '@angular/router';
import { LoginComponent } from '../components/login/login';
import { RegisterComponent } from '../components/register/register.component';
import { VerifyEmailComponent } from '../components/verify-email/verify-email.component';
import { LoginGuard } from '../../../core/guards/logged.guard';

export const AuthRoutes: Route[] = [
  {
    path: 'register',
    component: RegisterComponent,
    canActivate: [LoginGuard],
  },
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [LoginGuard],
  },
  {
    path: 'verify-email',
    component: VerifyEmailComponent,
  },
  {
    path: 'forgot-password',
    redirectTo: 'reset-password',
    pathMatch: 'full',
  },
  {
    path: 'reset-password',
    loadComponent: () => import('../components/reset-password/reset-password').then(m => m.ResetPassword),
    canActivate: [LoginGuard],
  },
];
