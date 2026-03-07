import { Component, inject, OnInit, signal, HostListener, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
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
    imports: [
        CommonModule,
        RouterModule,
        TranslateModule,
        MatIconModule,
        MatButtonModule,
        MatMenuModule,
        LoadingButtonComponent
    ],
    templateUrl: './navbar.component.html',
    styleUrl: './navbar.component.scss'
})
export class NavbarComponent implements OnInit {
    private localizationService = inject(LocalizationService);
    private authService = inject(AuthService);
    private responsiveService = inject(ResponsiveService);

    isLoggedIn = this.authService.isLoggedIn;
    isMobile = this.responsiveService.isMobile;

    isScrolled = signal(false);
    mobileMenuOpen = signal(false);

    private allNavLinks = [
        { path: '/', labelKey: 'nav.home', icon: 'home', public: true },
        { path: '/marketplace', labelKey: 'nav.market', icon: 'shopping_bag', authRequired: true },
        { path: '/categories', labelKey: 'nav.categories', icon: 'category', adminOnly: true },
        { path: '/subcategories', labelKey: 'nav.subcategories', icon: 'account_tree', adminOnly: true },
        { path: '/brands', labelKey: 'nav.brands', icon: 'branding_watermark', adminOnly: true },
        { path: '/items', labelKey: 'nav.products', icon: 'inventory_2', adminOnly: true },
        { path: '/dashboard', labelKey: 'nav.dashboard', icon: 'dashboard', adminOnly: true }
    ];

    filteredNavLinks = computed(() => {
        const loggedIn = this.isLoggedIn();
        const isAdmin = this.authService.isAdmin();

        return this.allNavLinks.filter(link => {
            if (link.public) return true;
            if (link.adminOnly) return loggedIn && isAdmin;
            if (link.authRequired) return loggedIn;
            return true;
        });
    });

    @HostListener('window:scroll', [])
    onWindowScroll() {
        this.isScrolled.set(window.scrollY > 20);
    }

    ngOnInit(): void { }

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
        this.mobileMenuOpen.update(v => !v);
    }

    closeMobileMenu() {
        this.mobileMenuOpen.set(false);
    }
}
