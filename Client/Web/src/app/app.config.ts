import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZonelessChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { routes } from './app.routes';
import { provideHttpClient, withInterceptors, withFetch } from '@angular/common/http';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { toasterInterceptor } from './core/interceptors/toaster.interceptor';
import { MessageService } from 'primeng/api';
import { providePrimeNG } from 'primeng/config';
import { provideTranslateService } from '@ngx-translate/core';
import { Preset } from './mytheme';
import { API_BASE_URL, AccountClient, CategoriesClient, SubcategoriesClient, ProductsClient, CustomersClient, TerritoriesClient, SalesClient, ReturnsClient, CalendarClient, Rentable_ItemsClient, Rent_RequestsClient, MediaFilesClient } from './core/api/api-client';
import { environment } from '../environments/environment';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZonelessChangeDetection(),
    provideRouter(routes),
    provideAnimationsAsync(),
    provideHttpClient(withInterceptors([authInterceptor, toasterInterceptor]), withFetch()),
    provideTranslateService({ fallbackLang: 'en' }),
    providePrimeNG({
      theme: {
        preset: Preset,
        options: { prefix: 'p', darkModeSelector: '.dark', cssLayer: false, },
      },
    }),
    MessageService,
    { provide: API_BASE_URL, useValue: environment.apiUrl },
    AccountClient,
    CategoriesClient,
    SubcategoriesClient,
    ProductsClient,
    CustomersClient,
    TerritoriesClient,
    SalesClient,
    ReturnsClient,
    CalendarClient,
    Rentable_ItemsClient,
    Rent_RequestsClient,
    MediaFilesClient,
  ]
};
