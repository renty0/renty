import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { AdminItemsClient, ReviewItemCommand } from '../../../core/api/api-client';
import { ToastService } from '../../../shared/services/toast.service';
import { HttpClient } from '@angular/common/http';

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
  private http = inject(HttpClient);
  private toast = inject(ToastService);

  items = signal<any[]>([]);
  isLoading = signal(true);
  isSaving = signal(false);

  displayedColumns: string[] = ['title', 'date', 'actions'];

  ngOnInit() {
    this.loadPendingItems();
  }

  loadPendingItems() {
    this.isLoading.set(true);
    this.http.get<any[]>('/api/v1/admin/items/pending').subscribe({
      next: (data) => {
        this.items.set(data || []);
        this.isLoading.set(false);
      },
      error: () => {
        this.toast.showError('Failed to load pending items');
        this.isLoading.set(false);
      }
    });
  }

  reviewItem(id: string, decision: 'approved' | 'rejected') {
    this.isSaving.set(true);
    this.itemsClient.reviewItem(id, new ReviewItemCommand({ status: decision, rejectionReason: `${decision} by admin` })).subscribe({
      next: () => {
        // Remove from list
        this.items.update(list => list.filter(i => i.id !== id));
      },
      error: (err) => console.error('Review failed', err)
    });
  }
}
