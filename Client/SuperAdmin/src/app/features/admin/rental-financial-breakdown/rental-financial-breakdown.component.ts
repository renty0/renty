import { Component, inject, signal, computed, DestroyRef, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatDividerModule } from '@angular/material/divider';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { finalize } from 'rxjs/operators';
import { AdminRentalFinancialsService, RentalFinancialBreakdownDto } from '../services/admin-rental-financials.service';

@Component({
  selector: 'app-rental-financial-breakdown',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatProgressBarModule,
    MatCardModule,
    MatChipsModule,
    MatDividerModule,
    TranslateModule,
    HeaderSectionComponent,
    FormsModule,
    MatInputModule,
    MatFormFieldModule
  ],
  templateUrl: './rental-financial-breakdown.component.html',
  styleUrl: './rental-financial-breakdown.component.scss'
})
export class RentalFinancialBreakdownComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private financialsService = inject(AdminRentalFinancialsService);
  private destroyRef = inject(DestroyRef);

  rentalId = signal<string | null>(null);
  searchId = signal<string>('');
  breakdown = signal<RentalFinancialBreakdownDto | null>(null);
  isLoading = signal(false);
  error = signal<string | null>(null);

  displayedColumns: string[] = ['createdAt', 'type', 'amount', 'isPending', 'description'];

  ngOnInit(): void {
    this.route.paramMap.pipe(takeUntilDestroyed(this.destroyRef)).subscribe(params => {
      const id = params.get('id');
      if (id) {
        this.rentalId.set(id);
        this.fetchBreakdown(id);
      } else {
        this.rentalId.set(null);
        this.breakdown.set(null);
      }
    });
  }

  fetchBreakdown(id: string): void {
    this.isLoading.set(true);
    this.error.set(null);
    this.financialsService.getRentalFinancialBreakdown(id)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => {
          if (response.success && response.data) {
            this.breakdown.set(response.data);
          } else {
            this.error.set(response.message || 'Failed to load breakdown');
          }
        },
        error: (err) => {
          this.error.set(err.error?.message || 'An error occurred while fetching financial data');
        }
      });
  }

  refresh(): void {
    const id = this.rentalId();
    if (id) {
      this.fetchBreakdown(id);
    }
  }

  onSearch(): void {
    const id = this.searchId().trim();
    if (id) {
      this.router.navigate(['/admin/rental-financials', id]);
    }
  }

  getStatusColor(status: string | undefined): string {
    if (!status) return 'primary';
    const s = status.toLowerCase();
    if (s === 'completed') return 'accent';
    if (s === 'cancelled' || s === 'disputed') return 'warn';
    return 'primary';
  }
}
