import { Injectable, inject, signal } from '@angular/core';
import { HubConnection, HubConnectionBuilder, HubConnectionState, LogLevel } from '@microsoft/signalr';
import { AuthService } from './auth.service';
import { environment } from '../../../environments/environment';

export interface SupportMessage {
  id: string;
  ticketId: string;
  senderId: number;
  senderName: string;
  senderRole: 'User' | 'Support' | 'Admin';
  message: string;
  createdAt: string;
}

export interface SupportAgent {
  id: number;
  name: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class SupportSignalrService {
  private authService = inject(AuthService);
  private hubConnection: HubConnection | null = null;

  isConnected = signal(false);
  newMessage = signal<SupportMessage | null>(null);
  activeAgents = signal<SupportAgent[]>([]);
  typingUser = signal<string | null>(null);

  private typingTimeout: any;

  async startConnection() {
    if (this.hubConnection?.state === HubConnectionState.Connected) return;

    const token = this.authService.getToken();
    if (!token) return;

    this.hubConnection = new HubConnectionBuilder()
      .withUrl(`${environment.apiUrl}/hubs/support`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .configureLogging(LogLevel.Warning)
      .build();

    // Incoming live message from any participant
    this.hubConnection.on('ReceiveSupportMessage', (msg: SupportMessage) => {
      this.newMessage.set(msg);
    });

    // An agent joined the ticket room
    this.hubConnection.on('AgentJoined', (agent: SupportAgent) => {
      this.activeAgents.update(agents => {
        if (agents.find(a => a.id === agent.id)) return agents;
        return [...agents, agent];
      });
    });

    // An agent left the ticket room
    this.hubConnection.on('AgentLeft', (agentId: number) => {
      this.activeAgents.update(agents => agents.filter(a => a.id !== agentId));
    });

    // Typing indicator
    this.hubConnection.on('UserTyping', (name: string) => {
      this.typingUser.set(name);
      clearTimeout(this.typingTimeout);
      this.typingTimeout = setTimeout(() => this.typingUser.set(null), 2500);
    });

    try {
      await this.hubConnection.start();
      this.isConnected.set(true);
    } catch (err) {
      console.error('SupportHub Connection Error:', err);
      setTimeout(() => this.startConnection(), 5000);
    }
  }

  async joinTicket(ticketId: string) {
    if (this.hubConnection?.state === HubConnectionState.Connected) {
      await this.hubConnection.invoke('JoinTicket', ticketId);
    }
  }

  async leaveTicket(ticketId: string) {
    if (this.hubConnection?.state === HubConnectionState.Connected) {
      await this.hubConnection.invoke('LeaveTicket', ticketId);
      this.activeAgents.set([]);
    }
  }

  async sendTyping(ticketId: string, senderName: string) {
    if (this.hubConnection?.state === HubConnectionState.Connected) {
      await this.hubConnection.invoke('TypingIndicator', ticketId, senderName);
    }
  }

  stopConnection() {
    this.hubConnection?.stop();
    this.isConnected.set(false);
  }
}
