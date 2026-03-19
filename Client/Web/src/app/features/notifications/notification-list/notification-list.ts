import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCardModule } from '@angular/material/card';
import { NotificationsClient, NotificationDto, ApiResponse, GetNotificationsResponse } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { ToastService } from '../../../shared/services/toast.service';
import { finalize, tap } from 'rxjs';

@Component({
  selector: 'app-notification-list',
  standalone: true,
  imports: [
    CommonModule,
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

  notifications = signal<NotificationDto[]>([]);
  unreadCount = signal(0);
  isLoading = signal(true);

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
            this.unreadCount.set(res.data.unreadCount || 0);
          }
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }

  markAsRead(id: string | undefined) {
    if (!id) return;
    this.notificationsClient.markNotificationRead(id)
      .pipe(
        tap((res: any) => {
          if (!res.error) {
            this.notifications.update(list =>
              list.map(n => n.id === id ? { ...n, isRead: true } as NotificationDto : n)
            );
            this.unreadCount.update(c => Math.max(0, c - 1));
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
            this.unreadCount.set(0);
            this.toast.showSuccess('notifications.markAllRead');
          }
        })
      ).subscribe();
  }
}
