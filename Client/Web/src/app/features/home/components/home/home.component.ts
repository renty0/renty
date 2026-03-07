import { Component, signal, HostListener, OnInit, AfterViewInit, ElementRef, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';

@Component({
    selector: 'app-home',
    standalone: true,
    imports: [
        CommonModule,
        RouterModule,
        TranslateModule,
        MatIconModule,
        LoadingButtonComponent
    ],
    templateUrl: './home.component.html',
    styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit, AfterViewInit {
    private el = inject(ElementRef);

    isScrolled = signal(false);

    categories = signal([
        { id: 1, nameKey: 'home.categories.electronics', icon: 'devices', image: 'assets/images/electronics.jpg' },
        { id: 2, nameKey: 'home.categories.tools', icon: 'construction', image: 'assets/images/tools.jpg' },
        { id: 3, nameKey: 'home.categories.furniture', icon: 'chair', image: 'assets/images/furniture.jpg' },
        { id: 4, nameKey: 'home.categories.cameras', icon: 'photo_camera', image: 'assets/images/cameras.jpg' },
        { id: 5, nameKey: 'home.categories.sports', icon: 'sports_soccer', image: 'assets/images/hero_bg.png' },
        { id: 6, nameKey: 'home.categories.party', icon: 'celebration', image: 'assets/images/hero_bg.png' }
    ]);

    stats = signal([
        { value: '50k+', labelKey: 'home.stats.items' },
        { value: '100+', labelKey: 'home.stats.cities' },
        { value: '25k+', labelKey: 'home.stats.users' },
        { value: '4.9/5', labelKey: 'home.stats.rating' }
    ]);

    steps = signal([
        { icon: 'search', titleKey: 'home.steps.find.title', descKey: 'home.steps.find.desc' },
        { icon: 'calendar_today', titleKey: 'home.steps.book.title', descKey: 'home.steps.book.desc' },
        { icon: 'shopping_bag', titleKey: 'home.steps.enjoy.title', descKey: 'home.steps.enjoy.desc' }
    ]);

    ngOnInit(): void {
        this.onWindowScroll();
    }

    ngAfterViewInit(): void {
        this.initScrollReveal();
    }

    @HostListener('window:scroll', [])
    onWindowScroll(): void {
        const scrollOffset = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
        this.isScrolled.set(scrollOffset > 50);
    }

    private initScrollReveal(): void {
        const observerOptions = {
            root: null,
            rootMargin: '0px',
            threshold: 0.15
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                }
            });
        }, observerOptions);

        const revealElements = this.el.nativeElement.querySelectorAll('.reveal');
        revealElements.forEach((el: HTMLElement) => observer.observe(el));
    }
}
