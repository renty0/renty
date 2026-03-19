import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, ChatListDto, ApiResponse, GetChatsResponse } from '../../../core/api/api-client';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { finalize, tap } from 'rxjs';

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
  
  chats = signal<ChatListDto[]>([]);
  isLoading = signal(true);

  ngOnInit() {
    this.loadChats();
  }

  loadChats() {
    this.isLoading.set(true);
    this.chatClient.getChats()
      .pipe(
        tap((res: ApiResponse<GetChatsResponse>) => {
          if (res.data?.chats) {
            this.chats.set(res.data.chats);
          }
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }
}
