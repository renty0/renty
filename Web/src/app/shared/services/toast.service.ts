import { Injectable, inject } from '@angular/core';
import { MessageService } from 'primeng/api';

export interface ToastConfig {
  sticky?: boolean;
  life?: number;
  closable?: boolean;
  key?: string;
  detail?: string;
}

@Injectable({
  providedIn: 'root',
})
export class ToastService {
  private messageService = inject(MessageService);

  showSuccess(message: string, config?: ToastConfig): void {
    this.showToast('success', 'Success', message, config);
  }
  showError(message: string, config?: ToastConfig): void {
    this.showToast('error', 'Error', message, config);
  }
  showInfo(message: string, config?: ToastConfig): void {
    this.showToast('info', 'Info', message, config);
  }
  showWarning(message: string, config?: ToastConfig): void {
    this.showToast('warn', 'Warning', message, config);
  }
  clear(key?: string): void {
    this.messageService.clear(key);
  }
  private showToast( severity: 'success' | 'error' | 'info' | 'warn', summary: string, detail: string, config?: ToastConfig ): void {
    const defaultConfig: ToastConfig = { life: 5000, closable: true, sticky: false };
    const finalConfig = { ...defaultConfig, ...config };
    this.messageService.add({
      severity, summary,
      detail: finalConfig.detail || detail,
      life: finalConfig.sticky ? undefined : finalConfig.life,
      closable: finalConfig.closable,
      key: finalConfig.key,
    });
  }
}
