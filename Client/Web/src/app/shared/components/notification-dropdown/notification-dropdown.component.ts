import { Component, inject, OnInit, signal, effect, HostListener, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { NotificationsClient, NotificationDto } from '../../../core/api/api-client';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-notification-dropdown',
  standalone: true,
  imports: [CommonModule, RouterModule, MatIconModule, MatButtonModule, MatBadgeModule, MatProgressSpinnerModule],
  templateUrl: './notification-dropdown.component.html',
  styleUrl: './notification-dropdown.component.scss',
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

  isOpen = signal(false);
  isLoading = signal(false);
  notifications = signal<NotificationDto[]>([]);
  
  unreadCount = signal(0);

  constructor() {
    effect(() => {
      const newNotif = this.signalrService.newNotification();
      if (newNotif) {
        this.notifications.update(current => {
          // Convert payload to NotificationDto
          const dto = new NotificationDto({
            id: newNotif.id,
            title: newNotif.title,
            message: newNotif.message,
            type: newNotif.type,
            actionUrl: newNotif.actionUrl,
            isRead: newNotif.isRead,
            createdAt: new Date(newNotif.createdAt)
          });
          
          return [dto, ...current];
        });
        this.updateUnreadCount();
        
        // Show toaster notification
        this.toastService.showInfo(`${newNotif.title} - ${newNotif.message}`);
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
      // Mark as read implicitly on click
      this.notificationsClient.markNotificationRead(notification.id!).subscribe(() => {
        this.notifications.update(current => 
          current.map(n => n.id === notification.id ? new NotificationDto({ ...n, isRead: true }) : n)
        );
        this.updateUnreadCount();
      });
    }

    if (notification.actionUrl) {
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

  getTimeAgo(date?: Date): string {
    if (!date) return '';
    const now = new Date();
    const diff = Math.floor((now.getTime() - date.getTime()) / 1000);
    
    if (diff < 60) return 'Just now';
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
    return date.toLocaleDateString();
  }
}
