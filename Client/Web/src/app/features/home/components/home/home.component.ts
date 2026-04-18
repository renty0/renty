import { Component, signal, HostListener, OnInit, AfterViewInit, ElementRef, inject, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { LoadingButtonComponent } from '../../../../shared/components/loading-button/loading-button.component';
import { TermsAndConditionsComponent } from '../../../auth/components/terms-and-conditions/terms-and-conditions.component';

type CalendarCell = {
    date: Date | null;
    dayNumber: number | null;
    isToday: boolean;
    isSelected: boolean;
};

@Component({
    selector: 'app-home',
    standalone: true,
    imports: [
        CommonModule,
        RouterModule,
        TranslateModule,
        MatIconModule,
        LoadingButtonComponent,
        TermsAndConditionsComponent
    ],
    templateUrl: './home.component.html',
    styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit, AfterViewInit {
    private el = inject(ElementRef);

    isScrolled = signal(false);
    showTerms = signal(false);

    private readonly today = new Date();
    calendarMonth = signal(new Date(this.today.getFullYear(), this.today.getMonth(), 1));
    selectedDate = signal<Date | null>(null);

    weekDays = computed(() => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);

    calendarLabel = computed(() => {
        const d = this.calendarMonth();
        return d.toLocaleString(undefined, { month: 'long', year: 'numeric' });
    });

    calendarCells = computed<CalendarCell[]>(() => this.buildCalendarCells(this.calendarMonth(), this.selectedDate()));

    categories = signal([
        { id: 1, nameKey: 'home.categories.watersports', icon: 'surfing', image: 'assets/images/category_watersports.png' },
        { id: 2, nameKey: 'home.categories.padel', icon: 'sports_tennis', image: 'assets/images/category_padel.png' },
        { id: 3, nameKey: 'home.categories.fitness', icon: 'fitness_center', image: 'assets/images/category_fitness.png' },
        { id: 4, nameKey: 'home.categories.football', icon: 'sports_soccer', image: 'assets/images/category_football.png' },
        { id: 5, nameKey: 'home.categories.cycling', icon: 'pedal_bike', image: 'assets/images/category_cycling.png' },
        { id: 6, nameKey: 'home.categories.camping', icon: 'terrain', image: 'assets/images/category_camping.png' }
    ]);

    stats = signal([
        { value: '10k+', labelKey: 'home.stats.items' },
        { value: '20+', labelKey: 'home.stats.cities' },
        { value: '15k+', labelKey: 'home.stats.users' },
        { value: '4.9/5', labelKey: 'home.stats.rating' }
    ]);

    topDestinations = signal([
        { nameKey: 'home.destinations.dahab', image: 'assets/images/hero_sports_egypt.png', descKey: 'home.destinations.dahabDesc' },
        { nameKey: 'home.destinations.gouna', image: 'assets/images/category_watersports.png', descKey: 'home.destinations.gounaDesc' },
        { nameKey: 'home.destinations.cairo', image: 'assets/images/category_padel.png', descKey: 'home.destinations.cairoDesc' },
        { nameKey: 'home.destinations.somabay', image: 'assets/images/category_watersports.png', descKey: 'home.destinations.somabayDesc' }
    ]);

    steps = signal([
        { icon: 'search', titleKey: 'home.steps.findTitle', descKey: 'home.steps.findDesc' },
        { icon: 'calendar_today', titleKey: 'home.steps.bookTitle', descKey: 'home.steps.bookDesc' },
        { icon: 'shopping_bag', titleKey: 'home.steps.enjoyTitle', descKey: 'home.steps.enjoyDesc' }
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

    prevMonth(): void {
        const d = this.calendarMonth();
        this.calendarMonth.set(new Date(d.getFullYear(), d.getMonth() - 1, 1));
    }

    nextMonth(): void {
        const d = this.calendarMonth();
        this.calendarMonth.set(new Date(d.getFullYear(), d.getMonth() + 1, 1));
    }

    selectCalendarCell(cell: CalendarCell): void {
        if (!cell.date) return;
        this.selectedDate.set(new Date(cell.date));
    }

    private buildCalendarCells(monthStart: Date, selected: Date | null): CalendarCell[] {
        const year = monthStart.getFullYear();
        const month = monthStart.getMonth();

        const firstDayOfMonth = new Date(year, month, 1);
        const lastDayOfMonth = new Date(year, month + 1, 0);

        const leadingEmpty = firstDayOfMonth.getDay(); // 0-6
        const totalDays = lastDayOfMonth.getDate();

        const cells: CalendarCell[] = [];

        for (let i = 0; i < leadingEmpty; i++) {
            cells.push({ date: null, dayNumber: null, isToday: false, isSelected: false });
        }

        for (let day = 1; day <= totalDays; day++) {
            const date = new Date(year, month, day);
            const isToday =
                date.getFullYear() === this.today.getFullYear() &&
                date.getMonth() === this.today.getMonth() &&
                date.getDate() === this.today.getDate();
            const isSelected =
                !!selected &&
                date.getFullYear() === selected.getFullYear() &&
                date.getMonth() === selected.getMonth() &&
                date.getDate() === selected.getDate();

            cells.push({ date, dayNumber: day, isToday, isSelected });
        }

        // pad to full weeks (multiple of 7)
        while (cells.length % 7 !== 0) {
            cells.push({ date: null, dayNumber: null, isToday: false, isSelected: false });
        }

        return cells;
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
