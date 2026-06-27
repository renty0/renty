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
import { LoadingButtonComponent } from '../loading-button/loading-button.component';
import { PermissionService } from '../../../core/services/permission.service';
import { PermissionType } from '../../../core/constants/permissions';
import { ResponsiveService } from '../../../core/services/responsive.service';
import { ThemeService } from '../../../core/services/theme.service';
import { NotificationDropdownComponent } from '../notification-dropdown/notification-dropdown.component';
import { environment } from '../../../../environments/environment';

@Component({
  selector: 'app-support-navbar',
  standalone: true,
  imports: [ CommonModule, RouterModule, TranslateModule, MatIconModule, MatButtonModule, MatMenuModule, FormsModule, NotificationDropdownComponent ],
  templateUrl: './support-navbar.html',
  styleUrl: './support-navbar.scss',
})
export class SupportNavbarComponent implements OnInit {
  private localizationService = inject(LocalizationService);
  public authService = inject(AuthService);
  private responsiveService = inject(ResponsiveService);
  private permissionService = inject(PermissionService);
  private router = inject(Router);

  isLoggedIn = this.authService.isLoggedIn;
  userData = computed(() => this.authService.getUserData());
  isMobile = this.responsiveService.isMobile;
  isExpert = computed(() => this.authService.isExpert());
  themeService = inject(ThemeService);
  isDarkMode = this.themeService.isDarkMode;

  // Permissions Signals
  canViewWallet = computed(() => this.permissionService.hasPermission(PermissionType.Wallet_View));
  canViewOrders = computed(() => this.permissionService.hasPermission(PermissionType.Orders_View));
  canViewRentals = computed(() => this.permissionService.hasPermission(PermissionType.Rentals_View));
  canViewItems = computed(() => this.permissionService.hasPermission(PermissionType.Items_View));
  canViewSupport = computed(() => this.permissionService.hasPermission(PermissionType.Complaints_View));
  canViewDashboard = computed(() => this.permissionService.hasPermission(PermissionType.Dashboards_View));
  canPostItems = computed(() => this.permissionService.hasPermission(PermissionType.Items_Create));

  // Show standard user menu items for any logged-in user
  isUser = computed(() => this.isLoggedIn());
  isOwnerRole = computed(() => this.authService.hasRole('Owner'));

  isScrolled = signal(false);
  mobileMenuOpen = signal(false);
  searchTerm = signal('');

  private allNavLinks = [
    { path: '/', labelKey: 'nav.home', icon: 'home', public: true },
    { path: '/about', labelKey: 'nav.about', icon: 'info', public: true },
    { path: '/contact', labelKey: 'nav.contact', icon: 'contact_support', public: true },
    { path: '/marketplace', labelKey: 'nav.market', icon: 'shopping_bag', authRequired: true },
    { path: '/categories', labelKey: 'nav.categories', icon: 'category', permission: PermissionType.Items_View },
    { path: '/subcategories', labelKey: 'nav.subcategories', icon: 'account_tree', permission: PermissionType.Items_View },
    { path: '/brands', labelKey: 'nav.brands', icon: 'branding_watermark', permission: PermissionType.Items_View },
    { path: '/items', labelKey: 'nav.products', icon: 'inventory_2', permission: PermissionType.Items_View },
  ];

  filteredNavLinks = computed(() => {
    const loggedIn = this.isLoggedIn();

    return this.allNavLinks.filter((link) => {
      if (link.public) return true;
      if (link.permission) return false; // Permissions moved to management dropdown
      if (link.authRequired) return loggedIn;
      return true;
    });
  });

  managementLinks = computed(() => {
    const loggedIn = this.isLoggedIn();
    if (!loggedIn) return [];

    const links = [];
    
    // Expert Actions
    if (this.isExpert()) {
      links.push({ path: '/expert/assigned', labelKey: 'expert.assigned.title', icon: 'fact_check' });
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

  toggleTheme() {
    this.themeService.toggleTheme();
  }

  logout() {
    this.authService.logout();
    this.mobileMenuOpen.set(false);
  }

  switchLang() {
    this.toggleLanguage();
  }

  get currentLang(): string {
    return this.localizationService.language();
  }

  userProfilePic = computed(() => {
    return (this.userData() as any)?.profilePictureUrl || 'assets/images/default-avatar.png';
  });

  userName = computed(() => {
    const data = this.userData();
    return data ? `${data.firstName} ${data.lastName}` : '';
  });

  toggleMobileMenu() {
    this.mobileMenuOpen.update((v) => !v);
  }

  closeMobileMenu() {
    this.mobileMenuOpen.set(false);
  }
}
