import { Injectable, inject } from '@angular/core';
import { MessageService } from 'primeng/api';
import { TranslateService } from '@ngx-translate/core';

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
  private translate = inject(TranslateService);

  showSuccess(message: string, config?: ToastConfig): void {
    this.showToast('success', 'common.success', message, config);
  }
  showError(message: string, config?: ToastConfig): void {
    this.showToast('error', 'common.error', message, config);
  }
  showInfo(message: string, config?: ToastConfig): void {
    this.showToast('info', 'common.info', message, config);
  }
  showWarning(message: string, config?: ToastConfig): void {
    this.showToast('warn', 'common.warning', message, config);
  }
  clear(key?: string): void {
    this.messageService.clear(key);
  }
  private showToast( severity: 'success' | 'error' | 'info' | 'warn', summary: string, detail: string, config?: ToastConfig ): void {
    const defaultConfig: ToastConfig = { life: 5000, closable: true, sticky: false };
    const finalConfig = { ...defaultConfig, ...config };
    const translatedSummary = this.translate.instant(summary);
    const translatedDetail = this.translate.instant(finalConfig.detail || detail);
    this.messageService.add({
      severity, summary: translatedSummary,
      detail: translatedDetail,
      life: finalConfig.sticky ? undefined : finalConfig.life,
      closable: finalConfig.closable,
      key: finalConfig.key,
    });
  }
}
