import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, SupportClient } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { finalize, tap, forkJoin } from 'rxjs';

@Component({
  selector: 'app-chat-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    MatListModule,
    MatIconModule,
    MatBadgeModule,
    MatProgressSpinnerModule,
    HeaderSectionComponent
  ],
  templateUrl: './chat-list.html',
  styleUrl: './chat-list.scss'
})
export class ChatListComponent implements OnInit {
  private chatClient = inject(ChatClient);
  private supportClient = inject(SupportClient);
  
  chats = signal<any[]>([]);
  isLoading = signal(true);

  ngOnInit() {
    this.loadChats();
  }

  loadChats() {
    this.isLoading.set(true);

    forkJoin({
      chatsRes: this.chatClient.getChats() as any,
      supportRes: this.supportClient.getSupportTickets() as any
    }).pipe(
      tap(({ chatsRes, supportRes }: any) => {
        let list: any[] = [];
        
        // Add normal chats
        const chatsList = chatsRes?.data?.chats ?? chatsRes?.data ?? (Array.isArray(chatsRes) ? chatsRes : []);
        list = [...chatsList];

        // Add single mandatory support chat
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
        
        list = [supportChat, ...list];
        
        // Sort by latest activity
        list.sort((a, b) => {
          const dateA = new Date(a.lastMessageAt || 0).getTime();
          const dateB = new Date(b.lastMessageAt || 0).getTime();
          return dateB - dateA;
        });

        this.chats.set(list);
      }),
      finalize(() => this.isLoading.set(false))
    ).subscribe();
  }
}
