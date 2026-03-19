import { Component, inject, OnInit, signal, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, ChatMessageDto, ApiResponse, GetChatMessagesResponse, PostChatMessageCommand, ChatMessageData } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { finalize, tap } from 'rxjs';

@Component({
  selector: 'app-chat-room',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    TranslateModule,
    FormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
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
  
  chatId = signal('');
  messages = signal<ChatMessageDto[]>([]);
  newMessage = signal('');
  isLoading = signal(true);
  isSending = signal(false);
  currentUserId = signal<number | null>(null);

  ngOnInit() {
    this.chatId.set(this.route.snapshot.paramMap.get('id') || '');
    this.currentUserId.set(this.auth.getCurrentUserId());

    if (this.chatId()) {
      this.loadMessages();
    }
  }

  ngAfterViewChecked() {
    this.scrollToBottom();
  }

  loadMessages() {
    this.isLoading.set(true);
    this.chatClient.getChatMessages(this.chatId())
      .pipe(
        tap((res: ApiResponse<GetChatMessagesResponse>) => {
          if (res.data?.messages) {
            this.messages.set(res.data.messages);
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
    const command = new PostChatMessageCommand({
      chatId: this.chatId(),
      message: this.newMessage()
    });

    this.chatClient.postChatMessage(this.chatId(), command)
      .pipe(
        tap((res: ApiResponse<ChatMessageData>) => {
          if (!res.error && res.data) {
            const newMsg = new ChatMessageDto({
              id: res.data.messageId,
              message: res.data.message,
              createdAt: res.data.createdAt,
              senderId: this.currentUserId() || 0, // Fallback if local ID unknown
              isRead: false
            });
            this.messages.update(msgs => [...msgs, newMsg]);
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
