import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient } from '../../../core/api/api-client';
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
  
  chats = signal<any[]>([]);
  isLoading = signal(true);

  ngOnInit() {
    this.loadChats();
  }

  loadChats() {
    this.isLoading.set(true);
    (this.chatClient.getChats() as any)
      .pipe(
        tap((res: any) => {
          const list = res?.data?.chats ?? res?.data ?? (Array.isArray(res) ? res : []);
          this.chats.set(list);
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }
}
