import { Injectable, inject } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { toast } from 'ngx-sonner';
import { LocalizationService } from '../../core/services/localization.service';

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
  private translate = inject(TranslateService);
  private localizationService = inject(LocalizationService);

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
    // Sonner doesn't have a simple global clear by key in this way, 
    // but we can dismiss all for now or skip if not critical.
    toast.dismiss();
  }

  private showToast( severity: 'success' | 'error' | 'info' | 'warn', summary: string, detail: string, config?: ToastConfig ): void {
    const defaultConfig: ToastConfig = { life: 4000, closable: true, sticky: false };
    const finalConfig = { ...defaultConfig, ...config };
    
    const translatedSummary = this.translate.instant(summary);
    let detailKey = finalConfig.detail || detail;
    if (detailKey === 'An unexpected server error occurred.') {
      detailKey = 'errors.unexpectedError';
    }
    const translatedDetail = this.translate.instant(detailKey);
    const message = `${translatedSummary}: ${translatedDetail}`;
    
    const options = {
      duration: finalConfig.sticky ? Infinity : finalConfig.life,
      invert: false, // Could be true for some themes
      dismissible: finalConfig.closable,
      style: {
        direction: this.localizationService.language() === 'ar' ? 'rtl' : 'ltr',
        fontFamily: 'inherit'
      }
    };

    switch (severity) {
      case 'success':
        toast.success(message, options);
        break;
      case 'error':
        toast.error(message, options);
        break;
      case 'warn':
        toast.warning(message, options);
        break;
      case 'info':
        toast.info(message, options);
        break;
      default:
        toast(message, options);
        break;
    }
  }
}

