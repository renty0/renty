import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, RouterOutlet } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'app-chat-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, RouterOutlet, MatListModule, MatIconModule, MatBadgeModule, MatProgressSpinnerModule, TranslateModule],
  templateUrl: './chat-layout.html',
  styleUrl: './chat-layout.scss'
})
export class ChatLayoutComponent implements OnInit {
  private chatClient = inject(ChatClient);
  private router = inject(Router);

  chats = signal<any[]>([]);
  isLoading = signal(true);
  activeChatId = signal<string | null>(null);

  ngOnInit() {
    this.loadChats();
    // Watch for route changes to highlight active chat
    this.activeChatId.set(this.getChatIdFromRoute());
  }

  loadChats() {
    this.isLoading.set(true);
    this.chatClient.getChats().subscribe(res => {
      this.chats.set((res as any) || []);
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
    this.router.navigate(['/chats', id]);
  }
}
