import { Injectable, inject, signal } from '@angular/core';
import { HubConnection, HubConnectionBuilder, HubConnectionState, LogLevel } from '@microsoft/signalr';
import { AuthService } from './auth.service';
import { environment } from '../../../environments/environment';

export interface NotificationPayload {
  id: string;
  title: string;
  message: string;
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

  constructor() {
    // Automatically connect if user is logged in
    if (this.authService.isLoggedIn()) {
      this.startConnection();
    }
  }

  async startConnection() {
    if (this.hubConnection?.state === HubConnectionState.Connected) return;

    const token = this.authService.getToken();
    if (!token) return;

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

    try {
      await this.hubConnection.start();
      this.isConnected.set(true);
      console.log('Notification SignalR Connected.');
    } catch (err) {
      console.error('Notification SignalR Connection Error: ', err);
      setTimeout(() => this.startConnection(), 5000);
    }
  }

  stopConnection() {
    this.hubConnection?.stop();
    this.isConnected.set(false);
  }
}
