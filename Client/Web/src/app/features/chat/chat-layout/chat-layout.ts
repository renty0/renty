import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule, RouterOutlet } from '@angular/router';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatBadgeModule } from '@angular/material/badge';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient } from '../../../core/api/api-client';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ConfirmDialogComponent } from '../../../shared/components/confirm-dialog/confirm-dialog.component';

import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-chat-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, RouterOutlet, MatListModule, MatIconModule, MatButtonModule, MatBadgeModule, MatProgressSpinnerModule, TranslateModule, MatDialogModule],
  templateUrl: './chat-layout.html',
  styleUrl: './chat-layout.scss'
})
export class ChatLayoutComponent implements OnInit {
  private chatClient = inject(ChatClient);
  private router = inject(Router);
  private translate = inject(TranslateService);
  private dialog = inject(MatDialog);

  chats = signal<any[]>([]);
  isLoading = signal(true);
  activeChatId = signal<string | null>(null);

  ngOnInit() {
    this.loadChats();
    this.activeChatId.set(this.getChatIdFromRoute());
  }

  loadChats() {
    this.isLoading.set(true);
    this.chatClient.getChats().subscribe((res: any) => {
      this.chats.set(res?.data?.chats || []);
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

  deleteChat(event: Event, id: string) {
    event.stopPropagation(); // Don't select the chat
    
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: this.translate.instant('common.delete'),
        message: this.translate.instant('chat.deleteConfirmation'),
        color: 'warn',
        confirmText: this.translate.instant('common.delete'),
        cancelText: this.translate.instant('common.cancel')
      }
    });

    dialogRef.afterClosed().subscribe(confirmed => {
      if (confirmed) {
        this.chatClient.deleteChat(id).subscribe(() => {
          this.loadChats();
          if (this.activeChatId() === id) {
            this.activeChatId.set(null);
            this.router.navigate(['/chats']);
          }
        });
      }
    });
  }
}
