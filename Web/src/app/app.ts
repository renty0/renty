import { ToastModule } from 'primeng/toast';
import { Component, effect, inject, Renderer2, signal, WritableSignal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';
import translationsEN from '../../public/i18n/en.json';
import translationsAR from '../../public/i18n/ar.json';
import { LocalizationService } from './core/services/localization.service';
import { ResponsiveService } from './core/services/responsive.service';
import { AuthService } from './core/services/auth.service';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';

@Component({
  selector: 'app-root',
  imports: [ RouterOutlet, ToastModule, ButtonModule, TooltipModule ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly title = signal('Rently');
  private translate = inject(TranslateService);
  private localizationService = inject(LocalizationService);
  private responsiveService = inject(ResponsiveService);
  private authService = inject(AuthService);
  language: 'ar' | 'en' = this.localizationService.language();
  private renderer = inject(Renderer2);
  isMobile = this.responsiveService.isMobile;
  sidenavOpened: WritableSignal<boolean>;

  constructor() {
    this.translate.addLangs(['ar', 'en']);
    this.translate.setTranslation('ar', translationsAR);
    this.translate.setTranslation('en', translationsEN);
    this.translate.setFallbackLang('en');
    this.sidenavOpened = signal(this.isMobile() === false);
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
