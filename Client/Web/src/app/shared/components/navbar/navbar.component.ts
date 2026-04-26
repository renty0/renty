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

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [ CommonModule, RouterModule, TranslateModule, MatIconModule, MatButtonModule, MatMenuModule, FormsModule, LoadingButtonComponent, NotificationDropdownComponent ],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss',
})
export class NavbarComponent implements OnInit {
  private localizationService = inject(LocalizationService);
  private authService = inject(AuthService);
  private responsiveService = inject(ResponsiveService);
  private permissionService = inject(PermissionService);
  private router = inject(Router);

  isLoggedIn = this.authService.isLoggedIn;
  userData = computed(() => this.authService.getUserData());
  isMobile = this.responsiveService.isMobile;
  isExpert = computed(() => this.authService.isExpert());
  themeService = inject(ThemeService);
  isDarkMode = this.themeService.isDarkMode;

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
    if (!loggedIn) return [];

    const links = [];
    const canViewSupport = this.permissionService.hasPermission(PermissionType.Complaints_View);
    const canViewDashboard = this.permissionService.hasPermission(PermissionType.Dashboards_View);
    const canViewUsers = this.permissionService.hasPermission(PermissionType.Users_View);
    const canViewRoles = this.permissionService.hasPermission(PermissionType.Roles_View);
    const canViewInventory = this.permissionService.hasPermission(PermissionType.Items_View);

    if (canViewSupport) {
      links.push({ path: '/support', labelKey: 'nav.support', icon: 'support_agent' });
    }

    if (canViewDashboard) {
      links.push({ path: '/admin/dashboard', labelKey: 'nav.dashboard', icon: 'dashboard' });
      links.push({ path: '/admin/gap-analysis', labelKey: 'nav.gap', icon: 'analytics' });
      links.push({ path: '/admin/fraud', labelKey: 'nav.fraud', icon: 'security' });
    }

    if (canViewUsers) {
      links.push({ path: '/admin/users', labelKey: 'nav.userManagement', icon: 'people' });
    }

    if (canViewRoles) {
      links.push({ path: '/admin/roles', labelKey: 'nav.roleManagement', icon: 'policy' });
    }

    if (canViewInventory) {
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

  toggleTheme() {
    this.themeService.toggleTheme();
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
