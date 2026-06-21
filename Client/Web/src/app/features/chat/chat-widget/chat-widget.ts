import { Component, inject, OnInit, OnDestroy, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { ChatSignalrService, ChatMessage } from '../../../core/services/chat-signalr.service';
import { ChatClient, PostChatMessageCommand } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { TranslateModule } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

interface ActiveChat {
  id: string;
  name: string;
  image?: string;
  messages: ChatMessage[];
  minimized: boolean;
  inputText: string;
  isLoading?: boolean;
}

import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-chat-widget',
  standalone: true,
  imports: [CommonModule, FormsModule, MatIconModule, MatButtonModule, TranslateModule, MatProgressSpinnerModule],
  templateUrl: './chat-widget.html',
  styleUrl: './chat-widget.scss'
})
export class ChatWidgetComponent implements OnInit, OnDestroy {
  private chatSignalr = inject(ChatSignalrService);
  private chatClient = inject(ChatClient);
  protected authService = inject(AuthService);

  activeChats = signal<ActiveChat[]>([]);
  isLoggedIn = this.authService.isLoggedIn;

  private messageSubscription?: Subscription;

  constructor() {
    // Listen for new messages
    this.messageSubscription = this.chatSignalr.newMessage$.subscribe(msg => {
      if (msg) {
        this.handleIncomingMessage(msg);
      }
    });
  }

  ngOnInit() {
    // We could load recent chats here if needed
  }

  ngOnDestroy() {
    if (this.messageSubscription) {
      this.messageSubscription.unsubscribe();
    }
  }

  handleIncomingMessage(msg: ChatMessage) {
    const chats = this.activeChats();
    const chatIndex = chats.findIndex(c => c.id === msg.chatId);
    
    if (chatIndex !== -1) {
      const updatedChats = [...chats];
      updatedChats[chatIndex].messages.push(msg);
      this.activeChats.set(updatedChats);
      // Auto-scroll to bottom (would need ViewChild)
    } else {
      // If chat not active, maybe show notification or open it automatically if it's new
      // For now, only handle active ones
    }
  }

  openChat(id: string, name: string, image?: string) {
    const chats = this.activeChats();
    if (chats.find(c => c.id === id)) return;

    if (chats.length >= 3) {
      chats.shift(); // Limit to 3 floating chats
    }

    this.activeChats.set([...chats, {
      id,
      name,
      image,
      messages: [],
      minimized: false,
      inputText: '',
      isLoading: true
    }]);

    (this.chatClient.getChatMessages(id) as any).subscribe((res: any) => {
      const messages = (res?.data?.messages || res?.data || res || []) as any[];
      this.activeChats.update(curr => curr.map(c => 
        c.id === id ? { ...c, messages, isLoading: false } : c
      ));
      this.chatSignalr.joinChat(id);
    });
  }

  closeChat(id: string) {
    this.activeChats.set(this.activeChats().filter(c => c.id !== id));
    this.chatSignalr.leaveChat(id);
  }

  toggleMinimize(id: string) {
    const updated = this.activeChats().map(c => 
      c.id === id ? { ...c, minimized: !c.minimized } : c
    );
    this.activeChats.set(updated);
  }

  sendMessage(chat: ActiveChat) {
    if (!chat.inputText.trim()) return;

    const command = new PostChatMessageCommand({ chatId: chat.id, message: chat.inputText });

    this.chatClient.postChatMessage(chat.id, command).subscribe((res: any) => {
      if (res) {
        // Clear input
        const updated = this.activeChats().map(c => 
          c.id === chat.id ? { ...c, inputText: '' } : c
        );
        this.activeChats.set(updated);
      }
    });
  }
}
