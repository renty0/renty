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
import { catchError, finalize, of, tap, firstValueFrom } from 'rxjs';
import { Router } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';
import { MatDialogModule } from '@angular/material/dialog';

export interface QueuedImage {
  file: File;
  previewUrl: string;
}

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

  chatId = signal('');
  messages = signal<any[]>([]);
  chatMetadata = signal<any>(null);
  newMessage = signal('');
  isLoading = signal(true);
  isSending = signal(false);
  currentUserId = signal<number | null>(null);

  selectedImages = signal<QueuedImage[]>([]);
  previewImage = signal<string | null>(null);

  constructor() {
    effect(() => {
      const msg = this.chatSignalr.newMessage();
      if (msg && msg.chatId === this.chatId()) {
        this.messages.update(msgs => {
          // If we already have the real message, ignore.
          if (msgs.some(m => m.id === msg.id)) return msgs;

          // Try to "upgrade" an optimistic message instead of appending (prevents duplicates).
          const optimisticIdx = msgs.findIndex(m =>
            m?.isOptimistic === true &&
            m?.senderId === msg.senderId &&
            m?.messageType === msg.messageType &&
            (m?.message ?? '') === (msg.message ?? '') &&
            // For media messages the optimistic mediaUrl is usually a blob: preview, so don't require equality.
            (msg.messageType === 0 || m?.mediaUrl === msg.mediaUrl || (typeof m?.mediaUrl === 'string' && m.mediaUrl.startsWith('blob:')))
          );

          if (optimisticIdx >= 0) {
            const copy = [...msgs];
            copy[optimisticIdx] = { ...msg, isOptimistic: false };
            return copy;
          }

          return [...msgs, msg];
        });

        setTimeout(() => this.scrollToBottom(), 100);
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

  onImagesSelected(event: any) {
    const files = event.target.files;
    if (files && files.length > 0) {
      const newImages: QueuedImage[] = [];
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        if (file.type.startsWith('image/')) {
          newImages.push({
            file,
            previewUrl: URL.createObjectURL(file)
          });
        }
      }
      this.selectedImages.update(imgs => [...imgs, ...newImages]);
      // Reset input
      event.target.value = '';
    }
  }

  removeQueuedImage(index: number) {
    this.selectedImages.update(imgs => {
      const copy = [...imgs];
      URL.revokeObjectURL(copy[index].previewUrl); // Free memory
      copy.splice(index, 1);
      return copy;
    });
  }

  openPreview(url: string) {
    this.previewImage.set(url);
  }

  closePreview() {
    this.previewImage.set(null);
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
        this.uploadAudioAndSend(file);
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

  private uploadAudioAndSend(file: File) {
    this.isSending.set(true);
    const fileParam: FileParameter = { data: file, fileName: file.name };

    // Add optimistic message
    const optimisticId = `temp_${Date.now()}`;
    const localUrl = URL.createObjectURL(file);

    this.messages.update(msgs => [...msgs, {
      id: optimisticId,
      message: null,
      mediaUrl: localUrl,
      senderId: this.currentUserId(),
      createdAt: new Date().toISOString(),
      messageType: 3, // Audio
      isOptimistic: true
    }]);
    setTimeout(() => this.scrollToBottom(), 50);

    this.mediaClient.uploadMedia(undefined, undefined, fileParam)
      .pipe(
        tap((res: any) => {
          if (res && res.data) {
             this.sendMediaMessage(res.data.url!, 3, undefined, optimisticId);
          }
        }),
        catchError(err => {
          this.removeOptimisticMessage(optimisticId);
          return of(null);
        }),
        finalize(() => this.isSending.set(false))
      ).subscribe();
  }

  private sendMediaMessage(url: string, type: number, text?: string, optimisticId?: string) {
    const cmd = new PostChatMessageCommand({
      chatId: this.chatId() as any,
      message: text,
      mediaUrl: url,
      messageType: type as any
    });

    this.chatClient.postChatMessage(this.chatId() as any, cmd)
      .pipe(
        tap((res: any) => {
          const data = res?.data;
          if (data && data.success) {
            // Replace optimistic message
            if (optimisticId) {
              this.messages.update(msgs => msgs.map(m => m.id === optimisticId ? {
                ...m,
                id: data.messageId,
                isOptimistic: false
              } : m));
            } else {
              this.messages.update(msgs => [...msgs, {
                  id: data.messageId,
                  message: text,
                  mediaUrl: url,
                  senderId: this.currentUserId(),
                  createdAt: data.createdAt,
                  messageType: type
              }]);
            }
            setTimeout(() => this.scrollToBottom(), 50);
          } else if (optimisticId) {
            this.removeOptimisticMessage(optimisticId);
          }
        }),
        catchError(err => {
          if (optimisticId) this.removeOptimisticMessage(optimisticId);
          return of(null);
        })
      ).subscribe();
  }

  async sendMessage() {
    const textMsg = this.newMessage().trim();
    const imgs = this.selectedImages();

    if (!textMsg && imgs.length === 0) return;
    if (this.isSending()) return;

    this.isSending.set(true);

    // Copy the items to send
    const imagesToSend = [...imgs];
    const messageToSend = textMsg;

    // Clear the inputs immediately for better UX
    this.newMessage.set('');
    this.selectedImages.set([]);

    try {
      if (imagesToSend.length > 0) {
        // Send images
        for (let i = 0; i < imagesToSend.length; i++) {
          const queuedImg = imagesToSend[i];
          const isFirstImage = i === 0;
          const caption = isFirstImage && messageToSend ? messageToSend : undefined;

          // Add optimistic image message
          const optimisticId = `temp_${Date.now()}_${i}`;
          this.messages.update(msgs => [...msgs, {
            id: optimisticId,
            message: caption,
            mediaUrl: queuedImg.previewUrl,
            senderId: this.currentUserId(),
            createdAt: new Date().toISOString(),
            messageType: 1, // Image
            isOptimistic: true
          }]);
          setTimeout(() => this.scrollToBottom(), 50);

          // Upload
          const fileParam: FileParameter = { data: queuedImg.file, fileName: queuedImg.file.name };
          const uploadRes = await firstValueFrom(this.mediaClient.uploadMedia(undefined, undefined, fileParam));

          if (uploadRes?.data?.url) {
            this.sendMediaMessage(uploadRes.data.url, 1, caption, optimisticId);
          } else {
            this.removeOptimisticMessage(optimisticId);
          }
        }
      } else if (messageToSend) {
        // Send text only
        const optimisticId = `temp_${Date.now()}`;
        this.messages.update(msgs => [...msgs, {
          id: optimisticId,
          message: messageToSend,
          senderId: this.currentUserId(),
          createdAt: new Date().toISOString(),
          messageType: 0, // Text
          isOptimistic: true
        }]);
        setTimeout(() => this.scrollToBottom(), 50);

        const cmd = new PostChatMessageCommand({
          chatId: this.chatId() as any,
          message: messageToSend,
          messageType: 0 as any
        });

        const res = await firstValueFrom(this.chatClient.postChatMessage(this.chatId() as any, cmd));
        if (res?.data?.success) {
          this.messages.update(msgs => msgs.map(m => m.id === optimisticId ? {
            ...m,
            id: res.data!.messageId,
            isOptimistic: false
          } : m));
        } else {
          this.removeOptimisticMessage(optimisticId);
        }
      }
    } catch (err) {
      console.error('Failed to send message', err);
    } finally {
      this.isSending.set(false);
    }
  }

  private removeOptimisticMessage(id: string) {
    this.messages.update(msgs => msgs.filter(m => m.id !== id));
  }

  private scrollToBottom(): void {
    try {
      this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
    } catch(err) { }
  }

  isCurrentUser(senderId: number | undefined): boolean {
    return senderId === this.currentUserId();
  }

  isUserOnline(): boolean {
    const lastLoginAt = this.chatMetadata()?.otherUserLastLoginAt;
    if (!lastLoginAt) return false;

    const lastLogin = new Date(lastLoginAt);
    const now = new Date();
    const diffInMinutes = (now.getTime() - lastLogin.getTime()) / (1000 * 60);

    // Consider user online if they logged in within the last 5 minutes
    return diffInMinutes <= 5;
  }

  getUserStatusText(): string {
    if (this.isUserOnline()) {
      return this.translate.instant('chat.activeNow');
    }

    const lastLoginAt = this.chatMetadata()?.otherUserLastLoginAt;
    if (!lastLoginAt) {
      return this.translate.instant('chat.offline');
    }

    const lastLogin = new Date(lastLoginAt);
    const now = new Date();
    const diffInMinutes = (now.getTime() - lastLogin.getTime()) / (1000 * 60);

    if (diffInMinutes < 60) {
      const minutes = Math.floor(diffInMinutes);
      return this.translate.instant('chat.lastSeenMinutes', { minutes });
    } else if (diffInMinutes < 24 * 60) {
      const hours = Math.floor(diffInMinutes / 60);
      return this.translate.instant('chat.lastSeenHours', { hours });
    } else {
      const days = Math.floor(diffInMinutes / (24 * 60));
      return this.translate.instant('chat.lastSeenDays', { days });
    }
  }
}
