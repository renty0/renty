import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDividerModule } from '@angular/material/divider';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
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
    MatChipsModule,
    MatIconModule,
    MatButtonModule,
    MatCardModule,
    MatDividerModule,
    MatProgressSpinnerModule,
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
      case 'pending':   return 'bg-yellow-50 text-yellow-700 border-1 border-yellow-100';
      case 'confirmed': return 'bg-indigo-50 text-indigo-700 border-1 border-indigo-100';
      case 'active':    return 'bg-primary-50 text-primary-700 border-1 border-primary-100';
      case 'completed': return 'bg-green-50 text-green-700 border-1 border-green-100';
      case 'cancelled':
      case 'rejected':  return 'bg-red-50 text-red-700 border-1 border-red-100';
      case 'overdue':   return 'bg-orange-50 text-orange-700 border-1 border-orange-100';
      case 'disputed':  return 'bg-purple-50 text-purple-700 border-1 border-purple-100';
      default:          return 'bg-gray-50 text-gray-700 border-1 border-gray-100';
    }
  }
}
