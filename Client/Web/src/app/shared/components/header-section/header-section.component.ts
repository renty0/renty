import { Component, inject, Input, Output, EventEmitter, OnInit, OnDestroy } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Subject, Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { AuthService } from '../../../core/services/auth.service';
import { LoadingButtonComponent } from '../loading-button/loading-button.component';

@Component({
  selector: 'app-header-section',
  imports: [MatIconModule, FormsModule, CommonModule, RouterModule, LoadingButtonComponent],
  templateUrl: './header-section.component.html',
  styleUrl: './header-section.component.scss',
})
export class HeaderSectionComponent implements OnInit, OnDestroy {
  private authService = inject(AuthService);

  @Input() title: string = '';
  @Input() placeholder: string = 'Search...';
  @Input() showSearch: boolean = true;
  @Input() showButton: boolean = true;
  @Input() searchTerm: string = '';
  @Input() debounceTimeMs: number = 500;
  @Output() searchTermChange = new EventEmitter<string>();
  @Output() searchChange = new EventEmitter<Event>();
  @Input() buttonText: string = 'Create';
  @Input() buttonLink: string | null = null;
  @Input() icon: string = 'add';
  @Input() buttonPermission: string | null = null;
  @Output() buttonClick = new EventEmitter<void>();

  private searchSubject = new Subject<Event>();
  private subscription?: Subscription;

  ngOnInit(): void {
    this.subscription = this.searchSubject
      .pipe(
        debounceTime(this.debounceTimeMs),
        distinctUntilChanged()
      )
      .subscribe(event => {
        this.searchChange.emit(event);
      });
  }

  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
  }

  onInputChange(event: Event) {
    this.searchSubject.next(event);
    this.searchTermChange.emit(this.searchTerm);
  }

  onButtonClick() {
    this.buttonClick.emit();
  }

  get canShowButton(): boolean {
    if (!this.showButton) return false;
    if (!this.buttonPermission) return true;
    if (this.authService.isSuperAdmin()) return true;
    return this.authService.hasPermission(this.buttonPermission);
  }
}
