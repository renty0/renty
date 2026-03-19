import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { OrdersClient, OrderListDto, ApiResponse, GetOrdersResponse } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { catchError, finalize, of, tap } from 'rxjs';

@Component({
  selector: 'app-my-orders',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    HeaderSectionComponent
  ],
  templateUrl: './my-orders.html',
  styleUrl: './my-orders.scss'
})
export class MyOrdersComponent implements OnInit {
  private ordersClient = inject(OrdersClient);
  private toast = inject(ToastService);
  public translate = inject(TranslateService);

  orders = signal<OrderListDto[]>([]);
  isLoading = signal(true);

  ngOnInit() {
    this.loadOrders();
  }

  loadOrders() {
    this.isLoading.set(true);
    this.ordersClient.getOrders()
      .pipe(
        tap((res: ApiResponse<GetOrdersResponse>) => {
          if (res.data?.orders) {
            this.orders.set(res.data.orders);
          }
        }),
        catchError(err => {
          this.toast.showError('errors.fetchFailed');
          return of(null);
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }

  getStatusColor(status?: string): string {
    switch (status?.toLowerCase()) {
      case 'pending': return 'warn';
      case 'paid': return 'primary';
      case 'shipped': return 'accent';
      case 'completed': return 'success';
      case 'cancelled': return 'error';
      default: return 'default';
    }
  }
}
