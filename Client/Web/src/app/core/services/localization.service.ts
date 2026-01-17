import { inject, Injectable, signal, PLATFORM_ID, Inject } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
@Injectable({
  providedIn: 'root',
})
export class LocalizationService {
  private languageSignal = signal<'ar' | 'en'>('en');
  language = this.languageSignal;
  private platformId = inject(PLATFORM_ID);
  private isBrowser: boolean;

  constructor() {
    this.isBrowser = isPlatformBrowser(this.platformId);
    this.languageSignal.set(this.getLanguage());
  }

  setLanguage(lang: 'ar' | 'en'): void {
    if (this.isBrowser) {
      localStorage.setItem('lang', lang);
    }
    this.languageSignal.set(lang);
  }
  getLanguage(): 'ar' | 'en' {
    if (!this.isBrowser) return 'en';
    const lang = localStorage.getItem('lang');
    return lang === 'ar' ? 'ar' : 'en';
  }
}
