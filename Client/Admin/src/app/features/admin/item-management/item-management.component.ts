import { Component, inject, signal, OnInit } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { AdminItemsClient, ReviewItemCommand, ItemListDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { LoadingButtonComponent } from '../../../shared/components/loading-button/loading-button.component';

@Component({
  selector: 'app-item-management',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatIconModule,
    MatTableModule,
    MatCardModule,
    MatProgressSpinnerModule,
    TranslateModule,
    HeaderSectionComponent,
    LoadingButtonComponent,
  ],
  templateUrl: './item-management.component.html',
  styleUrls: ['./item-management.component.scss']
})
export class ItemManagementComponent implements OnInit {
  private itemsClient = inject(AdminItemsClient);
  private toast = inject(ToastService);
  private router = inject(Router);

  items = signal<ItemListDto[]>([]);
  isLoading = signal(true);
  isSaving = signal(false);

  displayedColumns: string[] = ['title', 'date', 'status', 'actions'];

  ngOnInit() {
    this.loadPendingItems();
  }

  loadPendingItems() {
    this.isLoading.set(true);
    this.itemsClient.getPendingItems()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (res: any) => {
          if (!res.error) {
            this.items.set(res.data || []);
          } else {
            this.toast.showError(res.messages?.[0] || 'Failed to load pending items');
          }
        },
        error: () => this.toast.showError('Failed to load pending items')
      });
  }

  reviewItemOnPage(id: string) {
    this.router.navigate(['/items', id]);
  }

  reviewItem(id: string, decision: 'approved' | 'rejected') {
    this.isSaving.set(true);
    this.itemsClient.reviewItem(id, new ReviewItemCommand({ status: decision, rejectionReason: `${decision} by admin` }))
      .pipe(finalize(() => this.isSaving.set(false)))
      .subscribe({
        next: (res: any) => {
          if (!res.error) {
            this.items.update((list: ItemListDto[]) => list.filter((i: ItemListDto) => i.id !== id));
            this.toast.showSuccess(res.messages?.[0] || 'Item reviewed successfully');
          } else {
            this.toast.showError(res.messages?.[0] || 'Failed to review item');
          }
        },
        error: () => this.toast.showError('Failed to review item')
      });
  }
}
