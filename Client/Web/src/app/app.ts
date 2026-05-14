import { Component, computed, effect, inject, Renderer2, signal, WritableSignal } from '@angular/core';
import { Router, RouterOutlet, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { TranslateService } from '@ngx-translate/core';
import translationsEN from '../../public/i18n/en.json';
import translationsAR from '../../public/i18n/ar.json';
import { LocalizationService } from './core/services/localization.service';
import { ResponsiveService } from './core/services/responsive.service';
import { AuthService } from './core/services/auth.service';
import { MatButtonModule } from '@angular/material/button';
import { MatTooltipModule } from '@angular/material/tooltip';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './shared/components/navbar/navbar.component';
import { NgxSonnerToaster } from 'ngx-sonner';
import { ChatWidgetComponent } from './features/chat/chat-widget/chat-widget';
import { SupportHubComponent } from './shared/components/support-hub/support-hub';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, MatButtonModule, MatTooltipModule, NavbarComponent, NgxSonnerToaster, ChatWidgetComponent, SupportHubComponent],
  templateUrl: './app.html',
})
export class App {
  protected readonly title = signal('Renty');
  private translate = inject(TranslateService);
  private localizationService = inject(LocalizationService);
  private responsiveService = inject(ResponsiveService);
  private authService = inject(AuthService);
  private router = inject(Router);
  private renderer = inject(Renderer2);

  language: 'ar' | 'en' = this.localizationService.language();
  isMobile = this.responsiveService.isMobile;
  isLoggedIn = this.authService.isLoggedIn;
  sidenavOpened: WritableSignal<boolean>;

  currentRoute = signal('');
  isHomePage = computed(() => this.currentRoute() === '/' || this.currentRoute() === '');

  constructor() {
    this.translate.addLangs(['ar', 'en']);
    this.translate.setTranslation('ar', translationsAR);
    this.translate.setTranslation('en', translationsEN);
    this.translate.setFallbackLang('en');
    this.sidenavOpened = signal(this.isMobile() === false);
    this.router.events.pipe(filter(event => event instanceof NavigationEnd)).subscribe((event: any) => {
      this.currentRoute.set(event.urlAfterRedirects);
    });
    effect(() => {
      const lang = this.localizationService.language();
      this.translate.use(lang);
      const direction = lang === 'ar' ? 'rtl' : 'ltr';
      this.renderer.setAttribute(document.documentElement, 'dir', direction);
    });
  }

  logout() {
    this.authService.logout();
  }

  toggleLanguage() {
    const currentLang = this.localizationService.language();
    this.language = currentLang === 'en' ? 'ar' : 'en';
    this.localizationService.setLanguage(this.language);
  }

  getCurrentLanguageIcon(): string {
    return this.localizationService.language() === 'ar' ? 'pi pi-globe' : 'pi pi-language';
  }

  getCurrentLanguageTooltip(): string {
    return this.localizationService.language() === 'ar' ? 'Switch to English' : 'التبديل إلى العربية';
  }
}
