import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { NotificationsClient, NotificationDto, ApiResponse, GetNotificationsResponse } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ToastService } from '../../../shared/services/toast.service';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';
import { finalize, tap } from 'rxjs';

@Component({
  selector: 'app-notification-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatListModule,
    MatIconModule,
    MatButtonModule,
    MatProgressSpinnerModule,
    MatCardModule,
    HeaderSectionComponent
  ],
  templateUrl: './notification-list.html',
  styleUrl: './notification-list.scss'
})
export class NotificationListComponent implements OnInit {
  private notificationsClient = inject(NotificationsClient);
  private toast = inject(ToastService);
  private signalrService = inject(NotificationSignalrService);

  notifications = signal<NotificationDto[]>([]);
  isLoading = signal(true);

  // Use shared unreadCount from service (keeps navbar badge in sync)
  unreadCount = this.signalrService.unreadCount;

  ngOnInit() {
    this.loadNotifications();
  }

  loadNotifications() {
    this.isLoading.set(true);
    this.notificationsClient.getNotifications()
      .pipe(
        tap((res: ApiResponse<GetNotificationsResponse>) => {
          if (res.data) {
            this.notifications.set(res.data.notifications || []);
            // Sync shared count with server value
            this.signalrService.unreadCount.set(res.data.unreadCount || 0);
          }
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }

  markAsRead(id: string | undefined) {
    if (!id) return;
    const notif = this.notifications().find(n => n.id === id);
    if (notif?.isRead) return; // already read, skip
    this.notificationsClient.markNotificationRead(id)
      .pipe(
        tap((res: any) => {
          if (!res.error) {
            this.notifications.update(list =>
              list.map(n => n.id === id ? { ...n, isRead: true } as NotificationDto : n)
            );
            // Decrement shared badge count
            this.signalrService.unreadCount.update(c => Math.max(0, c - 1));
          }
        })
      ).subscribe();
  }

  markAllAsRead() {
    this.notificationsClient.markAllNotificationsRead()
      .pipe(
        tap((res: any) => {
          if (!res.error) {
            this.notifications.update(list =>
              list.map(n => ({ ...n, isRead: true } as NotificationDto))
            );
            // Reset shared badge count
            this.signalrService.unreadCount.set(0);
            this.toast.showSuccess('notifications.markAllRead');
          }
        })
      ).subscribe();
  }

  getIconForType(type?: string): string {
    switch (type) {
      case 'rental': return 'receipt_long';
      case 'chat': return 'chat';
      case 'support': return 'support_agent';
      case 'reminder': return 'notifications_active';
      case 'system': return 'info';
      default: return 'notifications';
    }
  }

  getTimeAgo(date?: Date | string): string {
    if (!date) return '';
    const d = typeof date === 'string' ? new Date(date) : date;
    const now = new Date();
    const diff = Math.floor((now.getTime() - d.getTime()) / 1000);
    
    if (diff < 60) return 'Just now';
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
    return d.toLocaleDateString();
  }
}
