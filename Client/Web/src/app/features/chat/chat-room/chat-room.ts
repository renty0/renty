import { Component, inject, OnInit, OnDestroy, signal, ViewChild, ElementRef, AfterViewChecked, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { ChatClient, MediaClient, PostChatMessageCommand, FileParameter, NotificationsClient } from '../../../core/api/api-client';
import { AuthService } from '../../../core/services/auth.service';
import { ChatSignalrService } from '../../../core/services/chat-signalr.service';
import { NotificationSignalrService } from '../../../core/services/notification-signalr.service';
import { catchError, finalize, of, tap, firstValueFrom, Subscription } from 'rxjs';
import { Router } from '@angular/router';
import { TranslateService } from '@ngx-translate/core';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule, MatSnackBar } from '@angular/material/snack-bar';
import { DomSanitizer } from '@angular/platform-browser';
import { environment } from '../../../../environments/environment';

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
    MatDialogModule,
    MatSnackBarModule
  ],
  templateUrl: './chat-room.html',
  styleUrl: './chat-room.scss'
})
export class ChatRoomComponent implements OnInit, AfterViewChecked, OnDestroy {
  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;

  private route = inject(ActivatedRoute);
  private chatClient = inject(ChatClient);
  private mediaClient = inject(MediaClient);
  private auth = inject(AuthService);
  private chatSignalr = inject(ChatSignalrService);
  private notificationsClient = inject(NotificationsClient);
  private notificationSignalr = inject(NotificationSignalrService);
  private router = inject(Router);
  private translate = inject(TranslateService);
  private sanitizer = inject(DomSanitizer);
  private snackBar = inject(MatSnackBar);

  chatId = signal('');
  messages = signal<any[]>([]);
  chatMetadata = signal<any>(null);
  newMessage = signal('');
  isLoading = signal(true);
  isSending = signal(false);
  currentUserId = signal<number | null>(null);

  selectedImages = signal<QueuedImage[]>([]);
  previewImage = signal<string | null>(null);

  private messageSubscription?: Subscription;

  constructor() {
    this.messageSubscription = this.chatSignalr.newMessage$.subscribe(rawMsg => {
      if (rawMsg && rawMsg.chatId === this.chatId()) {
        const msg = { ...rawMsg };
        if (msg.mediaUrl) {
          if (!msg.mediaUrl.startsWith('http')) {
            msg.mediaUrl = `${environment.apiUrl}/${msg.mediaUrl.replace(/^\//, '')}`;
          } else if (msg.mediaUrl.includes(`${environment.apiUrl}/${environment.apiUrl}`)) {
            msg.mediaUrl = msg.mediaUrl.replace(`${environment.apiUrl}/${environment.apiUrl}`, environment.apiUrl);
          } else if (msg.mediaUrl.includes(`${environment.apiUrl}/http`)) {
            // Fix edge cases where it prepends to an already absolute URL
            msg.mediaUrl = msg.mediaUrl.replace(`${environment.apiUrl}/http`, 'http');
          }
        }

        this.messages.update(msgs => {
          // If we already have the real message, ignore.
          if (msgs.some(m => m.id === msg.id)) return msgs;

          // Try to "upgrade" an optimistic message instead of appending (prevents duplicates).
          const optimisticIdx = msgs.findIndex(m =>
            m?.isOptimistic === true &&
            m?.messageType === msg.messageType
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

  ngOnDestroy() {
    if (this.messageSubscription) {
      this.messageSubscription.unsubscribe();
    }
    if (this.recordingInterval) {
      clearInterval(this.recordingInterval);
    }
  }

  loadMessages() {
    this.messages.set([]);
    this.chatMetadata.set(null);
    this.isLoading.set(true);
    this.chatClient.getChatMessages(this.chatId() as any)
      .pipe(
        tap((res: any) => {
          if (res && res.data && res.data.found) {
            this.messages.set(res.data.messages || []);
            this.chatMetadata.set(res.data.chatMetadata);
          }
          // Sync notification counter after chat messages are loaded and marked as read
          this.notificationsClient.getNotifications().subscribe((notifRes: any) => {
            if (notifRes?.data?.notifications) {
              const count = notifRes.data.notifications.filter((n: any) => !n.isRead).length;
              this.notificationSignalr.unreadCount.set(count);
            }
          });
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

  onFilesSelected(event: any) {
    const files = event.target.files;
    if (files && files.length > 0) {
      const newFiles: QueuedImage[] = [];
      let hasUnsupported = false;
      let hasTooLarge = false;
      
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        
        if (file.size > 10 * 1024 * 1024) {
          hasTooLarge = true;
          continue;
        }

        const isImage = file.type.startsWith('image/');
        const isVideo = file.type.startsWith('video/') || file.name.toLowerCase().endsWith('.webm');
        const isPdf = file.type === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf');
        
        if (isImage || isVideo || isPdf) {
          newFiles.push({
            file,
            previewUrl: URL.createObjectURL(file)
          });
        } else {
          hasUnsupported = true;
        }
      }
      
      if (hasTooLarge) {
        this.snackBar.open(this.translate.instant('chat.fileTooLarge'), this.translate.instant('common.close'), {
          duration: 5000,
          horizontalPosition: 'center',
          verticalPosition: 'bottom'
        });
      } else if (hasUnsupported) {
        this.snackBar.open(this.translate.instant('chat.unsupportedFileType'), this.translate.instant('common.close'), {
          duration: 4000,
          horizontalPosition: 'center',
          verticalPosition: 'bottom'
        });
      }
      
      this.selectedImages.update(imgs => [...imgs, ...newFiles]);
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

  isPdf(file: File): boolean {
    return file.type === 'application/pdf';
  }

  isVideo(file: File): boolean {
    return file.type.startsWith('video/');
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
      // Use higher bitrate for better quality
      const options = { audioBitsPerSecond: 128000 };
      this.mediaRecorder = new MediaRecorder(stream, options);
      this.audioChunks = [];
      this.recordingTime.set(0);

      this.mediaRecorder.ondataavailable = (event: any) => {
        this.audioChunks.push(event.data);
      };

      this.mediaRecorder.onstop = () => {
        clearInterval(this.recordingInterval);
        
        // Use the actual mime type the browser recorded in
        const actualMimeType = this.mediaRecorder.mimeType || 'audio/webm';
        const extension = actualMimeType.includes('mp4') ? 'mp4' : actualMimeType.includes('ogg') ? 'ogg' : 'webm';
        
        const audioBlob = new Blob(this.audioChunks, { type: actualMimeType });
        const file = new File([audioBlob], `voice-message.${extension}`, { type: actualMimeType });
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
    const safeUrl = this.sanitizer.bypassSecurityTrustUrl(localUrl);

    this.messages.update(msgs => [...msgs, {
      id: optimisticId,
      message: null,
      mediaUrl: safeUrl,
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
            if (optimisticId) {
              let fullUrl = url;
              if (!fullUrl.startsWith('http')) {
                 fullUrl = `${environment.apiUrl}/${fullUrl.replace(/^\//, '')}`;
              } else if (fullUrl.includes(`${environment.apiUrl}/${environment.apiUrl}`)) {
                 fullUrl = fullUrl.replace(`${environment.apiUrl}/${environment.apiUrl}`, environment.apiUrl);
              } else if (fullUrl.includes(`${environment.apiUrl}/http`)) {
                 fullUrl = fullUrl.replace(`${environment.apiUrl}/http`, 'http');
              }
              
              const realId = data.messageId;
              this.messages.update(msgs => {
                const alreadyExists = msgs.some(m => m.id === realId && !m.isOptimistic);
                if (alreadyExists) {
                  return msgs.filter(m => m.id !== optimisticId);
                }
                return msgs.map(m => m.id === optimisticId ? {
                  ...m,
                  id: realId,
                  mediaUrl: fullUrl,
                  isOptimistic: false
                } : m);
              });
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
          if (optimisticId) {
             this.removeOptimisticMessage(optimisticId);
             this.snackBar.open(this.translate.instant('chat.sendFailed'), this.translate.instant('common.close'), { duration: 4000, horizontalPosition: 'center', verticalPosition: 'bottom' });
          }
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

          const isPdf = queuedImg.file.type === 'application/pdf' || queuedImg.file.name.toLowerCase().endsWith('.pdf');
          const isVideo = queuedImg.file.type.startsWith('video/') || queuedImg.file.name.toLowerCase().endsWith('.webm');
          const msgType = isPdf ? 4 : isVideo ? 2 : 1; // 4 = Document, 2 = Video, 1 = Image

          // Add optimistic message
          const optimisticId = `temp_${Date.now()}_${i}`;
          this.messages.update(msgs => [...msgs, {
            id: optimisticId,
            message: caption,
            mediaUrl: queuedImg.previewUrl,
            senderId: this.currentUserId(),
            createdAt: new Date().toISOString(),
            messageType: msgType,
            isOptimistic: true
          }]);
          setTimeout(() => this.scrollToBottom(), 50);

          try {
            // Upload
            const fileParam: FileParameter = { data: queuedImg.file, fileName: queuedImg.file.name };
            const uploadRes = await firstValueFrom(this.mediaClient.uploadMedia(undefined, undefined, fileParam));

            if (uploadRes?.data?.url) {
              this.sendMediaMessage(uploadRes.data.url, msgType, caption, optimisticId);
            } else {
              this.removeOptimisticMessage(optimisticId);
              this.snackBar.open(this.translate.instant('chat.sendFailed'), this.translate.instant('common.close'), { duration: 4000, horizontalPosition: 'center', verticalPosition: 'bottom' });
            }
          } catch (uploadErr: any) {
            console.error('Upload failed', uploadErr);
            this.removeOptimisticMessage(optimisticId);
            
            // Check if it's a file size error
            const isSizeError = uploadErr?.response && (
              uploadErr.response.includes('10MB') || 
              uploadErr.response.includes('size cannot exceed') ||
              uploadErr.status === 413
            );
            
            const errorKey = isSizeError ? 'chat.fileTooLarge' : 'chat.sendFailed';
            this.snackBar.open(this.translate.instant(errorKey), this.translate.instant('common.close'), { duration: 5000, horizontalPosition: 'center', verticalPosition: 'bottom' });
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
          const realId = res.data!.messageId;
          this.messages.update(msgs => {
            const alreadyExists = msgs.some(m => m.id === realId && !m.isOptimistic);
            if (alreadyExists) {
              return msgs.filter(m => m.id !== optimisticId);
            }
            return msgs.map(m => m.id === optimisticId ? {
              ...m,
              id: realId,
              isOptimistic: false
            } : m);
          });
        } else {
          this.removeOptimisticMessage(optimisticId);
          this.snackBar.open(this.translate.instant('chat.sendFailed'), this.translate.instant('common.close'), { duration: 4000, horizontalPosition: 'center', verticalPosition: 'bottom' });
        }
      }
    } catch (err) {
      console.error('Failed to send message', err);
      // Catch any outer errors that weren't caught by inner catch blocks
      this.snackBar.open(this.translate.instant('chat.sendFailed'), this.translate.instant('common.close'), { duration: 4000, horizontalPosition: 'center', verticalPosition: 'bottom' });
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
