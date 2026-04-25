import { Component, inject, OnInit, signal, ViewChild, ElementRef, AfterViewChecked, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, PostChatMessageCommand } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { ChatSignalrService } from '../../../core/services/chat-signalr.service';
import { finalize, tap } from 'rxjs';

@Component({
  selector: 'app-chat-room',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    FormsModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule
  ],
  templateUrl: './chat-room.html',
  styleUrl: './chat-room.scss'
})
export class ChatRoomComponent implements OnInit, AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  
  private route = inject(ActivatedRoute);
  private chatClient = inject(ChatClient);
  private auth = inject(AuthService);
  private chatSignalr = inject(ChatSignalrService);
  
  chatId = signal('');
  messages = signal<any[]>([]);
  newMessage = signal('');
  isLoading = signal(true);
  isSending = signal(false);
  currentUserId = signal<number | null>(null);

  constructor() {
    effect(() => {
      const msg = this.chatSignalr.newMessage();
      if (msg && msg.chatId === this.chatId()) {
        if (!this.messages().find(m => m.id === msg.id)) {
           this.messages.update(msgs => [...msgs, msg]);
           setTimeout(() => this.scrollToBottom(), 100);
        }
      }
    });
  }

  ngOnInit() {
    this.currentUserId.set(this.auth.getCurrentUserId());
    this.route.params.subscribe(params => {
      const id = params['id'];
      if (id) {
        this.chatId.set(id);
        this.loadMessages();
        this.chatSignalr.joinChat(id);
      }
    });
  }

  ngAfterViewChecked() {
    this.scrollToBottom();
  }

  loadMessages() {
    this.isLoading.set(true);
    (this.chatClient.getChatMessages(this.chatId()) as any)
      .pipe(
        tap((res: any) => {
          if (res) {
            this.messages.set(res);
          }
        }),
        finalize(() => {
          this.isLoading.set(false);
          setTimeout(() => this.scrollToBottom(), 100);
        })
      ).subscribe();
  }

  sendMessage() {
    if (!this.newMessage().trim() || this.isSending()) return;

    this.isSending.set(true);
    this.chatClient.postChatMessage(this.chatId(), new PostChatMessageCommand({ chatId: this.chatId(), message: this.newMessage() }))
      .pipe(
        tap((res: any) => {
          if (res && res.data) {
            // Message will be added via SignalR effect if it broadcasts to caller too, 
            // but usually we add it manually for better UX
            const sentMsg = res.data;
            if (!this.messages().find(m => m.id === sentMsg.messageId)) {
                this.messages.update(msgs => [...msgs, {
                    id: sentMsg.messageId,
                    message: sentMsg.message,
                    senderId: this.currentUserId(),
                    createdAt: sentMsg.createdAt,
                    messageType: sentMsg.messageType
                }]);
            }
            this.newMessage.set('');
          }
        }),
        finalize(() => this.isSending.set(false))
      ).subscribe();
  }

  private scrollToBottom(): void {
    try {
      this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
    } catch(err) { }
  }

  isCurrentUser(senderId: number | undefined): boolean {
    return senderId === this.currentUserId();
  }
}
