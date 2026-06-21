import { Component, inject, OnInit, signal, effect, HostListener, ElementRef, untracked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { TranslatePipe } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { NotificationsClient, NotificationDto } from '../../../core/api/api-client';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { ToastService } from '../../services/toast.service';
import { LocalizedNotificationPipe } from '../../pipes/localized-notification.pipe';
import { LocalizationService } from '../../../core/services/localization.service';

@Component({
  selector: 'app-notification-dropdown',
  standalone: true,
  imports: [CommonModule, RouterModule, MatIconModule, MatButtonModule, MatBadgeModule, MatProgressSpinnerModule, TranslatePipe, LocalizedNotificationPipe],
  templateUrl: './notification-dropdown.component.html',
  styleUrl: './notification-dropdown.component.scss',
  providers: [LocalizedNotificationPipe],
  animations: [
    trigger('dropdownAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.95) translateY(-10px)' }),
        animate('150ms cubic-bezier(0, 0, 0.2, 1)', style({ opacity: 1, transform: 'scale(1) translateY(0)' }))
      ]),
      transition(':leave', [
        animate('100ms cubic-bezier(0.4, 0, 1, 1)', style({ opacity: 0, transform: 'scale(0.95) translateY(-10px)' }))
      ])
    ])
  ]
})
export class NotificationDropdownComponent implements OnInit {
  private notificationsClient = inject(NotificationsClient);
  private signalrService = inject(NotificationSignalrService);
  private router = inject(Router);
  private eRef = inject(ElementRef);
  private toastService = inject(ToastService);
  private localizedNotificationPipe = inject(LocalizedNotificationPipe);
  public localizationService = inject(LocalizationService);

  isOpen = signal(false);
  isLoading = signal(false);
  notifications = signal<NotificationDto[]>([]);
  unreadCount = this.signalrService.unreadCount;

  private visibleCount = signal(7);
  readonly PAGE_SIZE = 5;

  visibleNotifications = () => this.notifications().slice(0, this.visibleCount());
  hasMore = () => this.visibleCount() < this.notifications().length;

  constructor() {
    effect(() => {
      const newNotif = this.signalrService.newNotification();
      if (newNotif) {
        untracked(() => {
          const isActiveUrl = newNotif.actionUrl && this.router.url === newNotif.actionUrl;

          this.notifications.update(current => {
            const dto = new NotificationDto({
              id: newNotif.id,
              title: newNotif.title,
              message: newNotif.message,
              titleAr: newNotif.titleAr,
              messageAr: newNotif.messageAr,
              type: newNotif.type,
              actionUrl: newNotif.actionUrl,
              isRead: isActiveUrl ? true : newNotif.isRead,
              createdAt: new Date(newNotif.createdAt)
            });
            
            if (!current.find(n => n.id === dto.id)) {
              return [dto, ...current];
            }
            return current;
          });
          this.updateUnreadCount();
          
          if (isActiveUrl) {
            // Tell the backend it's read since the user is actively viewing it
            this.notificationsClient.markNotificationRead(newNotif.id).subscribe();
          }

          // Show a toast unless it's a chat notification and we're actively in that chat room
          if (!(isActiveUrl && newNotif.type === 'chat')) {
            const isAr = this.localizationService.language() === 'ar';
            const title = (isAr && newNotif.titleAr) ? newNotif.titleAr : this.localizedNotificationPipe.transform(newNotif.title);
            const message = (isAr && newNotif.messageAr) ? newNotif.messageAr : this.localizedNotificationPipe.transform(newNotif.message, true);
            this.toastService.showInfo(`${title} - ${message}`);
          }
        });
      }
    }, { allowSignalWrites: true });
  }

  ngOnInit() {
    this.loadNotifications();
  }

  @HostListener('document:click', ['$event'])
  clickout(event: Event) {
    if (this.isOpen() && !this.eRef.nativeElement.contains(event.target)) {
      this.isOpen.set(false);
    }
  }

  toggleDropdown() {
    this.isOpen.update(v => !v);
    if (this.isOpen()) {
      this.visibleCount.set(7);
    }
  }

  onBodyScroll(event: Event) {
    const el = event.target as HTMLElement;
    const threshold = 40; 
    if (el.scrollHeight - el.scrollTop - el.clientHeight <= threshold) {
      this.loadMore();
    }
  }

  loadMore() {
    if (this.hasMore()) {
      this.visibleCount.update(v => v + this.PAGE_SIZE);
    }
  }

  loadNotifications() {
    this.isLoading.set(true);
    this.notificationsClient.getNotifications().subscribe({
      next: (res) => {
        if (res.data?.notifications) {
          this.notifications.set(res.data.notifications);
          this.updateUnreadCount();
        }
        this.isLoading.set(false);
      },
      error: () => {
        this.isLoading.set(false);
      }
    });
  }

  updateUnreadCount() {
    const count = this.notifications().filter(n => !n.isRead).length;
    this.unreadCount.set(count);
  }

  markAsRead(notification: NotificationDto, event: Event) {
    event.stopPropagation();
    if (notification.isRead) return;

    this.notificationsClient.markNotificationRead(notification.id!).subscribe(() => {
      this.notifications.update(current => 
        current.map(n => n.id === notification.id ? new NotificationDto({ ...n, isRead: true }) : n)
      );
      this.updateUnreadCount();
    });
  }

  markAllAsRead(event: Event) {
    event.stopPropagation();
    if (this.unreadCount() === 0) return;

    this.notificationsClient.markAllNotificationsRead().subscribe(() => {
      this.notifications.update(current => 
        current.map(n => new NotificationDto({ ...n, isRead: true }))
      );
      this.updateUnreadCount();
    });
  }

  onNotificationClick(notification: NotificationDto) {
    if (!notification.isRead) {
      this.notificationsClient.markNotificationRead(notification.id!).subscribe(() => {
        this.notifications.update(current => 
          current.map(n => n.id === notification.id ? new NotificationDto({ ...n, isRead: true }) : n)
        );
        this.updateUnreadCount();
      });
    }

    if (notification.actionUrl) {
      console.log(notification);
      
      this.router.navigateByUrl(notification.actionUrl);
      this.isOpen.set(false);
    }
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
    
    const isAr = this.localizationService.language() === 'ar';
    if (diff < 60) return isAr ? 'الآن' : 'Just now';
    if (diff < 3600) return isAr ? `منذ ${Math.floor(diff / 60)} دقيقة` : `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return isAr ? `منذ ${Math.floor(diff / 3600)} ساعة` : `${Math.floor(diff / 3600)}h ago`;
    if (diff < 604800) return isAr ? `منذ ${Math.floor(diff / 86400)} يوم` : `${Math.floor(diff / 86400)}d ago`;
    return d.toLocaleDateString(isAr ? 'ar-EG' : 'en-US');
  }
}
