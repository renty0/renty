import {
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZonelessChangeDetection,
} from '@angular/core';
import { provideRouter, withInMemoryScrolling } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideNativeDateAdapter } from '@angular/material/core';
import { routes } from './app.routes';
import { provideHttpClient, withInterceptors, withFetch } from '@angular/common/http';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { provideTranslateService } from '@ngx-translate/core';
import { CookieService } from 'ngx-cookie-service';
import { API_BASE_URL } from './core/api/api-client';
import { PROVIDE_API_CLIENTS } from './core/api/api-providers';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZonelessChangeDetection(),
    provideHttpClient(withFetch(), withInterceptors([authInterceptor])),
    provideRouter(routes, withInMemoryScrolling({ anchorScrolling: 'enabled' })),
    provideAnimationsAsync(),
    provideNativeDateAdapter(),
    provideTranslateService({ fallbackLang: 'en' }),
    { provide: API_BASE_URL, useValue: environment.apiUrl },
    CookieService,
    ...PROVIDE_API_CLIENTS
  ],
};
