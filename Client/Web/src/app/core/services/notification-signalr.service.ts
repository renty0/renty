import { Injectable, inject, signal } from '@angular/core';
import { HubConnection, HubConnectionBuilder, HubConnectionState, LogLevel } from '@microsoft/signalr';
import { AuthService } from './auth.service';
import { environment } from '../../../environments/environment';

export interface NotificationPayload {
  id: string;
  title: string;
  message: string;
  titleAr?: string;
  messageAr?: string;
  type: string;
  actionUrl?: string;
  isRead: boolean;
  createdAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationSignalrService {
  private authService = inject(AuthService);
  private hubConnection: HubConnection | null = null;
  
  isConnected = signal(false);
  newNotification = signal<NotificationPayload | null>(null);
  unreadCount = signal(0);

  private connectionPromise: Promise<void> | null = null;

  constructor() {
    if (this.authService.isLoggedIn()) {
      this.startConnection();
    }
  }

  startConnection(): Promise<void> {
    if (this.hubConnection?.state === HubConnectionState.Connected) return Promise.resolve();
    if (this.connectionPromise) return this.connectionPromise;

    const token = this.authService.getToken();
    if (!token) return Promise.resolve();

    this.hubConnection = new HubConnectionBuilder()
      .withUrl(`${environment.apiUrl}/hubs/notifications`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .configureLogging(LogLevel.Information)
      .build();

    this.hubConnection.on('ReceiveNotification', (payload: NotificationPayload) => {
      this.newNotification.set(payload);
    });

    this.connectionPromise = this.hubConnection.start()
      .then(() => {
        this.isConnected.set(true);
        this.connectionPromise = null;
        console.log('Notification SignalR Connected.');
      })
      .catch(err => {
        console.error('Notification SignalR Connection Error: ', err);
        this.connectionPromise = null;
        setTimeout(() => this.startConnection(), 5000);
      });

    return this.connectionPromise;
  }

  stopConnection() {
    this.hubConnection?.stop();
    this.isConnected.set(false);
  }
}
