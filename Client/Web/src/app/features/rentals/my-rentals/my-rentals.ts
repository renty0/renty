import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTabsModule } from '@angular/material/tabs';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RentalsClient, RentalListDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-my-rentals',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatTableModule,
    MatChipsModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatTabsModule,
    MatTooltipModule,
    HeaderSectionComponent
  ],
  templateUrl: './my-rentals.html',
  styleUrl: './my-rentals.scss'
})
export class MyRentalsComponent implements OnInit {
  private rentalsClient = inject(RentalsClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  isLoading = signal(true);
  rentals = signal<RentalListDto[]>([]);
  filteredRentals = signal<RentalListDto[]>([]);
  activeStatus = signal<string | null>(null);

  displayedColumns: string[] = ['item', 'dates', 'amount', 'status', 'actions'];

  ngOnInit() {
    this.loadRentals();
  }

  loadRentals() {
    this.isLoading.set(true);
    this.rentalsClient.getRentals(1, 100, undefined).subscribe({
      next: (res) => {
        const rentalsList = res.data?.rentals || [];
        this.rentals.set(rentalsList);
        this.applyFilter(this.activeStatus());
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load rentals', err);
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  applyFilter(status: string | null) {
    this.activeStatus.set(status);
    if (!status) {
      this.filteredRentals.set(this.rentals());
    } else {
      this.filteredRentals.set(this.rentals().filter(r => r.status?.toLowerCase() === status.toLowerCase()));
    }
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'pending': return 'warn';
      case 'approved': return 'accent';
      case 'active': return 'primary';
      case 'completed': return 'success';
      case 'cancelled':
      case 'rejected': return 'error';
      default: return 'default';
    }
  }
}
