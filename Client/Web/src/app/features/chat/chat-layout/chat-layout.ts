import { Component, inject, OnInit, OnDestroy, signal, effect } from '@angular/core';

import { Router, RouterModule, RouterOutlet } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, SupportClient } from '../../../core/api/api-client';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { ChatSignalrService } from '../../../core/services/chat-signalr.service';
import { AuthService } from '../../../core/services/auth.service';
import { Subscription, forkJoin } from 'rxjs';

@Component({
  selector: 'app-chat-layout',
  standalone: true,
  imports: [RouterModule, RouterOutlet, MatListModule, MatIconModule, MatButtonModule, MatBadgeModule, MatProgressSpinnerModule, TranslateModule, MatDialogModule],
  templateUrl: './chat-layout.html',
  styleUrl: './chat-layout.scss'
})
export class ChatLayoutComponent implements OnInit, OnDestroy {
  private chatClient = inject(ChatClient);
  private supportClient = inject(SupportClient);
  private router = inject(Router);
  private translate = inject(TranslateService);
  private chatSignalr = inject(ChatSignalrService);
  private auth = inject(AuthService);

  chats = signal<any[]>([]);
  isLoading = signal(true);
  activeChatId = signal<string | null>(null);

  private messageSubscription?: Subscription;

  constructor() {
    this.messageSubscription = this.chatSignalr.newMessage$.subscribe(msg => {
      if (msg) {
        this.chats.update(currentChats => {
          let updated = false;
          const newChats = currentChats.map(c => {
            if (c.id === msg.chatId) {
              updated = true;
              let msgText = msg.message;
              if (!msgText && msg.messageType !== 0) {
                msgText = msg.messageType === 1 ? '[صورة]' : msg.messageType === 2 ? '[فيديو]' : msg.messageType === 3 ? '[صوت]' : '[وسائط]';
              }
              const isUnread = msg.senderId !== this.auth.getCurrentUserId() && this.activeChatId() !== msg.chatId;
              return {
                ...c,
                lastMessage: msgText,
                lastMessageAt: msg.createdAt,
                unreadCount: isUnread ? (c.unreadCount || 0) + 1 : c.unreadCount
              };
            }
            return c;
          });
          
          if (!updated) {
            // If the chat isn't in the list, reload to fetch the new chat
            setTimeout(() => this.loadChats(), 500);
            return currentChats;
          }
          
          return newChats.sort((a, b) => new Date(b.lastMessageAt).getTime() - new Date(a.lastMessageAt).getTime());
        });
      }
    });
  }

  ngOnInit() {
    this.loadChats();
    this.activeChatId.set(this.getChatIdFromRoute());
  }

  ngOnDestroy() {
    if (this.messageSubscription) {
      this.messageSubscription.unsubscribe();
    }
  }

  loadChats() {
    this.isLoading.set(true);
    forkJoin({
      chatsRes: this.chatClient.getChats() as any,
      supportRes: this.supportClient.getSupportTickets() as any
    }).subscribe(({ chatsRes, supportRes }: any) => {
      let loadedChats = chatsRes?.data?.chats || [];
      
      const ticketsList = supportRes?.data?.tickets ?? supportRes?.data ?? (Array.isArray(supportRes) ? supportRes : []);
      let lastSupportMessage = 'chat.supportPlaceholder';
      let lastSupportDate = new Date().toISOString();
      
      if (ticketsList.length > 0) {
        lastSupportMessage = ticketsList[0].lastMessage || ticketsList[0].subject || 'chat.supportPlaceholder';
        lastSupportDate = ticketsList[0].updatedAt || ticketsList[0].createdAt;
      }

      const supportChat = {
        id: 'support',
        otherUserFirstName: 'Support',
        otherUserLastName: 'Team',
        otherUserProfileImage: null,
        lastMessage: lastSupportMessage,
        lastMessageType: 0,
        unreadCount: 0,
        lastMessageAt: lastSupportDate,
        isSupport: true
      };
      
      loadedChats = [supportChat, ...loadedChats];
      loadedChats.sort((a: any, b: any) => new Date(b.lastMessageAt || 0).getTime() - new Date(a.lastMessageAt || 0).getTime());

      const activeId = this.activeChatId();
      if (activeId) {
        loadedChats = loadedChats.map((c: any) => c.id === activeId ? { ...c, unreadCount: 0 } : c);
      }
      this.chats.set(loadedChats);
      this.isLoading.set(false);
    });
  }

  getChatIdFromRoute(): string | null {
    const url = this.router.url;
    const parts = url.split('/');
    return parts.length > 2 ? parts[2] : null;
  }

  selectChat(id: string | undefined) {
    if (!id) return;
    this.activeChatId.set(id);
    
    // Clear unread count optimistically
    this.chats.update(chats => chats.map(c => c.id === id ? { ...c, unreadCount: 0 } : c));
    
    if (id === 'support') {
      this.router.navigate(['/chats', id], { queryParams: { type: 'support' } });
    } else {
      this.router.navigate(['/chats', id]);
    }
  }
}
