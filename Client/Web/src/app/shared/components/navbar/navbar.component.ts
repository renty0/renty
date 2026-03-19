import { Component, inject, OnInit, signal, HostListener, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { LocalizationService } from '../../../core/services/localization.service';
import { AuthService } from '../../../core/services/auth.service';
import { ResponsiveService } from '../../../core/services/responsive.service';
import { LoadingButtonComponent } from '../loading-button/loading-button.component';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [ CommonModule, RouterModule, TranslateModule, MatIconModule, MatButtonModule, MatMenuModule, FormsModule, LoadingButtonComponent ],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss',
})
export class NavbarComponent implements OnInit {
  private localizationService = inject(LocalizationService);
  private authService = inject(AuthService);
  private responsiveService = inject(ResponsiveService);
  private router = inject(Router);

  isLoggedIn = this.authService.isLoggedIn;
  isAdmin = computed(() => this.authService.isAdmin());
  isExpert = computed(() => this.authService.isExpert());
  isMobile = this.responsiveService.isMobile;

  isScrolled = signal(false);
  mobileMenuOpen = signal(false);
  searchTerm = signal('');

  private allNavLinks = [
    { path: '/', labelKey: 'nav.home', icon: 'home', public: true },
    { path: '/marketplace', labelKey: 'nav.market', icon: 'shopping_bag', authRequired: true },
    { path: '/categories', labelKey: 'nav.categories', icon: 'category', adminOnly: true },
    {
      path: '/subcategories',
      labelKey: 'nav.subcategories',
      icon: 'account_tree',
      adminOnly: true,
    },
    { path: '/brands', labelKey: 'nav.brands', icon: 'branding_watermark', adminOnly: true },
    { path: '/items', labelKey: 'nav.products', icon: 'inventory_2', adminOnly: true },
  ];

  filteredNavLinks = computed(() => {
    const loggedIn = this.isLoggedIn();

    return this.allNavLinks.filter((link) => {
      if (link.public) return true;
      if (link.adminOnly) return false; // Admin links moved to dropdown
      if (link.authRequired) return loggedIn;
      return true;
    });
  });

  managementLinks = computed(() => {
    const loggedIn = this.isLoggedIn();
    const isAdmin = this.isAdmin();
    const isSupport = this.authService.isSupport();

    if (!loggedIn) return [];

    const links = [];

    if (isSupport || isAdmin) {
      links.push({ path: '/support', labelKey: 'nav.supportTitle', icon: 'support_agent' });
    }

    if (isAdmin) {
      links.push({
        path: '/admin/dashboard',
        labelKey: 'nav.dashboardTitle',
        icon: 'dashboard',
      });
      links.push({ path: '/admin/gap-analysis', labelKey: 'nav.gapTitle', icon: 'analytics' });
      links.push({ path: '/admin/fraud', labelKey: 'nav.fraudTitle', icon: 'security' });
      links.push({ path: '/admin/users', labelKey: 'nav.userManagementTitle', icon: 'people' });
      links.push(...this.allNavLinks.filter((link) => link.adminOnly));
    }

    return links;
  });

  onSearch() {
    const term = this.searchTerm().trim();
    if (term) {
      this.router.navigate(['/search'], { queryParams: { q: term } });
      this.searchTerm.set('');
      this.closeMobileMenu();
    }
  }

  @HostListener('window:scroll', [])
  onWindowScroll() {
    this.isScrolled.set(window.scrollY > 20);
  }

  ngOnInit(): void {}

  toggleLanguage() {
    const currentLang = this.localizationService.language();
    const newLang = currentLang === 'en' ? 'ar' : 'en';
    this.localizationService.setLanguage(newLang);
  }

  get isArabic(): boolean {
    return this.localizationService.language() === 'ar';
  }

  logout() {
    this.authService.logout();
    this.mobileMenuOpen.set(false);
  }

  toggleMobileMenu() {
    this.mobileMenuOpen.update((v) => !v);
  }

  closeMobileMenu() {
    this.mobileMenuOpen.set(false);
  }
}
