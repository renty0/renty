import { Component, computed, effect, inject, Renderer2, signal, WritableSignal, OnDestroy, untracked } from '@angular/core';
import { Router, RouterOutlet, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { Subscription } from 'rxjs';
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
import { NotificationSignalrService } from './core/services/notification-signalr.service';
import { ChatSignalrService } from './core/services/chat-signalr.service';
import { ToastService } from './shared/services/toast.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, MatButtonModule, MatTooltipModule, NavbarComponent, NgxSonnerToaster, ChatWidgetComponent],
  templateUrl: './app.html',
})
export class App implements OnDestroy {
  protected readonly title = signal('Renty');
  private translate = inject(TranslateService);
  private localizationService = inject(LocalizationService);
  private responsiveService = inject(ResponsiveService);
  private authService = inject(AuthService);
  private router = inject(Router);
  private renderer = inject(Renderer2);
  private notificationSignalr = inject(NotificationSignalrService);
  private chatSignalr = inject(ChatSignalrService);
  private toastService = inject(ToastService);

  language: 'ar' | 'en' = this.localizationService.language();
  isMobile = this.responsiveService.isMobile;
  isLoggedIn = this.authService.isLoggedIn;
  sidenavOpened: WritableSignal<boolean>;

  currentRoute = signal('');
  isHomePage = computed(() => this.currentRoute() === '/' || this.currentRoute() === '');
  private messageSubscription?: Subscription;

  constructor() {
    this.translate.addLangs(['ar', 'en']);
    this.translate.setTranslation('ar', translationsAR as any);
    this.translate.setTranslation('en', translationsEN as any);
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

    effect(() => {
      const newNotif = this.notificationSignalr.newNotification();
      if (newNotif) {
        untracked(() => {
          const lang = this.localizationService.language();
          const msg = lang === 'ar' && newNotif.messageAr ? newNotif.messageAr : newNotif.message;
          // Check type to show proper severity, but we can default to info
          if (newNotif.type === 'success' || newNotif.type === 'wallet') {
              this.toastService.showSuccess(msg);
          } else if (newNotif.type === 'error' || newNotif.type === 'failed') {
              this.toastService.showError(msg);
          } else {
              this.toastService.showInfo(msg);
          }
          
          // Increment the unread count when a new notification arrives
          this.notificationSignalr.unreadCount.update(c => c + 1);
        });
      }
    }, { allowSignalWrites: true });

    this.messageSubscription = this.chatSignalr.newMessage$.subscribe(msg => {
      if (!msg) return;
      const currentUrl = this.router.url;
      // If we are NOT currently on the chat page for this specific chat, show a toast.
      if (!currentUrl.includes(`/chat/${msg.chatId}`)) {
        // Suppress notification if already there
        this.toastService.showInfo(`New message: ${msg.message || '...'}`);
      }
    });
  }

  ngOnDestroy() {
    if (this.messageSubscription) {
      this.messageSubscription.unsubscribe();
    }
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
