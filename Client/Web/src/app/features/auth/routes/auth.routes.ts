import { Route } from '@angular/router';
import { LoginComponent } from '../components/login/login';
import { RegisterComponent } from '../components/register/register.component';
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
];
