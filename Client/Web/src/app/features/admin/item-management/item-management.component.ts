import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';

export interface PendingItem {
  id: string;
  titleEn: string;
  descEn: string;
  ownerId: string;
  createdAt: string;
  status: string;
}

@Component({
  selector: 'app-item-management',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './item-management.component.html',
  styleUrls: ['./item-management.component.scss']
})
export class ItemManagementComponent implements OnInit {
  private http = inject(HttpClient);

  items = signal<PendingItem[]>([]);
  isLoading = signal(false);

  ngOnInit() {
    this.fetchPendingItems();
  }

  fetchPendingItems() {
    this.isLoading.set(true);
    // In a real scenario, this would be /api/v1/admin/items?status=PendingApproval
    // We mock the fetch assuming the items list endpoint supports status filtering
    this.http.get<any>('/api/v1/items?status=PendingApproval').subscribe({
      next: (res) => {
        // assuming standard paginated response
        this.items.set(res.items || res);
        this.isLoading.set(false);
      },
      error: () => this.isLoading.set(false) // Handle gracefully
    });
  }

  reviewItem(id: string, status: 'approved' | 'rejected') {
    this.http.post(`/api/v1/admin/items/${id}/review`, { status, rejectionReason: status === 'rejected' ? 'Violates terms of use' : null }).subscribe({
      next: () => {
        // Remove from list
        this.items.update(list => list.filter(i => i.id !== id));
      },
      error: (err) => console.error('Review failed', err)
    });
  }
}
