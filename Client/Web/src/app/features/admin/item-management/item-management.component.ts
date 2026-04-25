import { Component, inject, signal, OnInit } from '@angular/core';
import { finalize } from 'rxjs';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { AdminItemsClient, ReviewItemCommand, ItemListDto } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';

@Component({
  selector: 'app-item-management',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatCardModule,
    MatChipsModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './item-management.component.html',
  styleUrls: ['./item-management.component.scss']
})
export class ItemManagementComponent implements OnInit {
  private itemsClient = inject(AdminItemsClient);
  private toast = inject(ToastService);

  items = signal<ItemListDto[]>([]);
  isLoading = signal(true);
  isSaving = signal(false);

  displayedColumns: string[] = ['title', 'date', 'actions'];

  ngOnInit() {
    this.loadPendingItems();
  }

  loadPendingItems() {
    this.isLoading.set(true);
    this.itemsClient.getPendingItems()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error) {
            this.items.set(res.data || []);
          } else {
            this.toast.showError(res.messages?.[0] || 'Failed to load pending items');
          }
        },
        error: () => this.toast.showError('Failed to load pending items')
      });
  }

  reviewItem(id: string, decision: 'approved' | 'rejected') {
    this.isSaving.set(true);
    this.itemsClient.reviewItem(id, new ReviewItemCommand({ status: decision, rejectionReason: `${decision} by admin` }))
      .pipe(finalize(() => this.isSaving.set(false)))
      .subscribe({
        next: (res) => {
          if (!res.error) {
            this.items.update(list => list.filter(i => i.id !== id));
            this.toast.showSuccess(res.messages?.[0] || 'Item reviewed successfully');
          } else {
            this.toast.showError(res.messages?.[0] || 'Failed to review item');
          }
        },
        error: () => this.toast.showError('Failed to review item')
      });
  }
}
