import { Route } from '@angular/router';
import { LoginComponent } from '../components/login/login';
import { RegisterComponent } from '../components/register/register.component';

export const AuthRoutes: Route[] = [
  {
    path: 'register',
    component: RegisterComponent,
  },
  {
    path: 'login',
    component: LoginComponent,
  },
];
