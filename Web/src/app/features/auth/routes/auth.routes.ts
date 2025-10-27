import { Route } from '@angular/router';
import { LoginGuard } from '../../../core/guards/logged.guard';
import { LoginComponent } from '../components/login/login';
import { ResetPassword } from '../components/reset-password/reset-password';

export const AuthRoutes: Route[] = [
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [LoginGuard]
  },
  // {
  //   path: 'register',
  //   component: RegisterComponent,
  //   canActivate: [LoginGuard]
  // },
  // {
  //   path: 'confirm-email',
  //   component: ConfirmEmailComponent,
  //   canActivate: [LoginGuard]
  // },
  {
    path: 'forgot-password',
    component: ResetPassword,
    canActivate: [LoginGuard]
  },
];
