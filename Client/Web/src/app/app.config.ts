import {
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZonelessChangeDetection,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { routes } from './app.routes';
import { provideHttpClient, withInterceptors, withFetch } from '@angular/common/http';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { MessageService } from 'primeng/api';
import { providePrimeNG } from 'primeng/config';
import { provideTranslateService } from '@ngx-translate/core';
import { Preset } from './mytheme';
import { CookieService } from 'ngx-cookie-service';
import {
  API_BASE_URL,
  CategoriesClient,
  SubcategoriesClient,
  RecommendationsClient,
  AuthClient,
  MediaClient,
  BrandsClient,
  ItemsClient,
} from './core/api/api-client';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZonelessChangeDetection(),
    provideHttpClient(withFetch(), withInterceptors([authInterceptor])),
    provideRouter(routes),
    provideAnimationsAsync(),
    provideTranslateService({ fallbackLang: 'en' }),
    providePrimeNG({
      theme: {
        preset: Preset,
        options: { prefix: 'p', darkModeSelector: '.dark', cssLayer: false },
      },
    }),
    MessageService,
    { provide: API_BASE_URL, useValue: environment.apiUrl },
    CategoriesClient,
    SubcategoriesClient,
    RecommendationsClient,
    AuthClient,
    MediaClient,
    BrandsClient,
    CookieService,
    ItemsClient,
  ],
};
