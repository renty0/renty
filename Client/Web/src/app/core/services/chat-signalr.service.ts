import { Injectable, inject, signal } from '@angular/core';
import { HubConnection, HubConnectionBuilder, HubConnectionState, LogLevel } from '@microsoft/signalr';
import { AuthService } from './auth.service';
import { environment } from '../../../environments/environment';

export interface ChatMessage {
  id: string;
  chatId: string;
  senderId: number;
  message?: string;
  mediaUrl?: string;
  messageType: number;
  contextItemId?: string;
  createdAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class ChatSignalrService {
  private authService = inject(AuthService);
  private hubConnection: HubConnection | null = null;
  
  isConnected = signal(false);
  newMessage = signal<ChatMessage | null>(null);
  userTyping = signal<{chatId: string, userId: number} | null>(null);

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
      .withUrl(`${environment.apiUrl}/hubs/chat`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .configureLogging(LogLevel.Information)
      .build();

    this.hubConnection.on('ReceiveMessage', (payload: any) => {
      this.newMessage.set(payload);
    });

    this.hubConnection.on('UserTyping', (userId: number, chatId: string) => {
      this.userTyping.set({ chatId, userId });
    });

    try {
      await this.hubConnection.start();
      this.isConnected.set(true);
      console.log('SignalR Connected.');
    } catch (err) {
      console.error('SignalR Connection Error: ', err);
      setTimeout(() => this.startConnection(), 5000);
    }
  }

  async joinChat(chatId: string) {
    if (this.hubConnection?.state !== HubConnectionState.Connected) {
      await this.startConnection();
    }
    if (this.hubConnection?.state === HubConnectionState.Connected) {
      await this.hubConnection.invoke('JoinChat', chatId);
    }
  }

  async leaveChat(chatId: string) {
    if (this.hubConnection?.state !== HubConnectionState.Connected) return;
    await this.hubConnection.invoke('LeaveChat', chatId);
  }

  async sendTypingIndicator(chatId: string) {
    if (this.hubConnection?.state !== HubConnectionState.Connected) {
      await this.startConnection();
    }
    if (this.hubConnection?.state === HubConnectionState.Connected) {
      await this.hubConnection.invoke('TypingIndicator', chatId);
    }
  }

  stopConnection() {
    this.hubConnection?.stop();
    this.isConnected.set(false);
  }
}
