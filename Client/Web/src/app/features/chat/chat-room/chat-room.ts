import { Component, inject, OnInit, signal, ViewChild, ElementRef, AfterViewChecked, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, MediaClient, PostChatMessageCommand, FileParameter } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { ChatSignalrService } from '../../../core/services/chat-signalr.service';
import { catchError, finalize, of, tap } from 'rxjs';
import { Router } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { ConfirmDialogComponent } from '../../../shared/components/confirm-dialog/confirm-dialog.component';

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
    MatProgressSpinnerModule,
    MatDialogModule
  ],
  templateUrl: './chat-room.html',
  styleUrl: './chat-room.scss'
})
export class ChatRoomComponent implements OnInit, AfterViewChecked {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  
  private route = inject(ActivatedRoute);
  private chatClient = inject(ChatClient);
  private mediaClient = inject(MediaClient);
  private auth = inject(AuthService);
  private chatSignalr = inject(ChatSignalrService);
  private router = inject(Router);
  private translate = inject(TranslateService);
  private dialog = inject(MatDialog);
  
  chatId = signal('');
  messages = signal<any[]>([]);
  chatMetadata = signal<any>(null);
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
    this.chatClient.getChatMessages(this.chatId() as any)
      .pipe(
        tap((res: any) => {
          if (res && res.data && res.data.found) {
            this.messages.set(res.data.messages || []);
            this.chatMetadata.set(res.data.chatMetadata);
          }
        }),
        catchError(err => {
            console.error('Failed to load messages', err);
            return of(null);
        }),
        finalize(() => {
          this.isLoading.set(false);
          setTimeout(() => this.scrollToBottom(), 100);
        })
      ).subscribe();
  }

  isRecording = signal(false);
  recordingTime = signal(0);
  private mediaRecorder: any;
  private audioChunks: any[] = [];
  private recordingInterval: any;

  onImageSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.uploadFile(file, 1); // 1 = Image
    }
  }

  startRecording() {
    if (this.isRecording()) return;
    
    navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
      this.mediaRecorder = new MediaRecorder(stream);
      this.audioChunks = [];
      this.recordingTime.set(0);
      
      this.mediaRecorder.ondataavailable = (event: any) => {
        this.audioChunks.push(event.data);
      };
      
      this.mediaRecorder.onstop = () => {
        clearInterval(this.recordingInterval);
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/wav' });
        const file = new File([audioBlob], 'voice-message.wav', { type: 'audio/wav' });
        this.uploadFile(file, 3); // 3 = Audio
        stream.getTracks().forEach(track => track.stop());
      };
      
      this.mediaRecorder.start();
      this.isRecording.set(true);
      
      this.recordingInterval = setInterval(() => {
        this.recordingTime.update(t => t + 1);
      }, 1000);

    }).catch(err => {
      console.error('Mic access denied', err);
    });
  }

  stopRecording() {
    if (!this.isRecording()) return;
    this.mediaRecorder.stop();
    this.isRecording.set(false);
  }

  getFormattedTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  private uploadFile(file: File, type: number) {
    this.isLoading.set(true);
    const fileParam: FileParameter = { data: file, fileName: file.name };
    this.mediaClient.uploadMedia(undefined, undefined, fileParam)
      .pipe(
        tap((res: any) => {
          if (res && res.data) {
             this.sendMediaMessage(res.data.url!, type);
          }
        }),
        finalize(() => this.isLoading.set(false))
      ).subscribe();
  }

  private sendMediaMessage(url: string, type: number) {
    const cmd = new PostChatMessageCommand({
      chatId: this.chatId() as any,
      message: undefined,
      mediaUrl: url,
      messageType: type as any
    });

    this.chatClient.postChatMessage(this.chatId() as any, cmd)
      .pipe(
        tap((res: any) => {
          const data = res?.data;
          if (data && data.success) {
            this.messages.update(msgs => [...msgs, {
                id: data.messageId,
                message: null,
                mediaUrl: url,
                senderId: this.currentUserId(),
                createdAt: data.createdAt,
                messageType: type
            }]);
            setTimeout(() => this.scrollToBottom(), 50);
          }
        })
      ).subscribe();
  }

  sendMessage() {
    if (!this.newMessage().trim() || this.isSending()) return;

    this.isSending.set(true);
    const cmd = new PostChatMessageCommand({
      chatId: this.chatId() as any,
      message: this.newMessage(),
      messageType: 0 as any // Text
    });

    this.chatClient.postChatMessage(this.chatId() as any, cmd)
      .pipe(
        tap((res: any) => {
          const data = res?.data;
          if (data && data.success) {
            const sentMsg = data;
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
            setTimeout(() => this.scrollToBottom(), 50);
          }
        }),
        catchError(err => {
            console.error('Failed to send message', err);
            return of(null);
        }),
        finalize(() => this.isSending.set(false))
      ).subscribe();
  }

  deleteCurrentChat() {
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
        this.chatClient.deleteChat(this.chatId()).subscribe(() => {
          this.router.navigate(['/chats']);
        });
      }
    });
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
