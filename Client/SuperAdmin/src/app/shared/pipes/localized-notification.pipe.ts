import { Pipe, PipeTransform, inject } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { LocalizationService } from '../../core/services/localization.service';

@Pipe({
  name: 'localizedNotification',
  standalone: true,
  pure: false
})
export class LocalizedNotificationPipe implements PipeTransform {
  private translate = inject(TranslateService);
  private localizationService = inject(LocalizationService);

  transform(value: string | undefined, isMessage: boolean = false): string {
    if (!value) return '';
    if (this.localizationService.language() !== 'ar') return value;

    if (!isMessage) {
        // Known titles
        switch (value) {
            case 'Expert Evaluation Complete': return 'اكتمل تقييم الخبير';
            case 'New Message': return 'رسالة جديدة';
            case 'Payment Confirmed': return 'تم تأكيد الدفع';
            case 'Order Delivered!': return 'تم توصيل الطلب!';
            case 'Item approved': return 'تمت الموافقة على المنتج';
            case 'New Expert Task': return 'مهمة خبير جديدة';
            case 'Item rejected': return 'تم رفض المنتج';
            case 'Reminder': return 'تذكير';
            case 'ID Verification Rejected': return 'تم رفض توثيق الهوية';
            case 'ID Verification Approved': return 'تم قبول توثيق الهوية';
            default: return this.translate.instant(value);
        }
    } else {
        // Dynamic messages - Regex matchers
        
        // "hamza2 sent you a message: hi"
        let match = value.match(/^(.+) sent you a message: (.+)$/);
        if (match) return `${match[1]} أرسل لك رسالة: ${match[2]}`;

        // "Your payment of $10.00 via card has been confirmed."
        match = value.match(/^Your payment of (.+) via (.+) has been confirmed\.$/);
        if (match) return `تم تأكيد دفعك بمبلغ ${match[1]} عبر ${match[2]}.`;

        // "The expert has completed the evaluation for 'cycle'. Status: Approved."
        match = value.match(/^The expert has completed the evaluation for '(.+)'. Status: (.+)\.$/);
        if (match) {
            const statusEn = match[2];
            let statusAr = statusEn;
            if (statusEn.toLowerCase().includes('approved')) statusAr = 'مقبول';
            else if (statusEn.toLowerCase().includes('rejected')) statusAr = 'مرفوض';
            return `أكمل الخبير التقييم لـ '${match[1]}'. الحالة: ${statusAr}.`;
        }

        // "Your order has been delivered. Enjoy your item!"
        if (value.includes('Your order has been delivered')) return 'تم توصيل طلبك. استمتع به!';

        match = value.match(/^A new item verification has been requested for '(.+)'\.?$/);
        if (match) return `تم طلب فحص منتج جديد لـ '${match[1]}'`;

        // "Your item 'Title' has been approved and is now live."
        match = value.match(/^Your item '(.+)' has been approved and is now live\.$/);
        if (match) return `تمت الموافقة على منتجك '${match[1]}' وهو الآن معروض.`;

        // "Your item 'Title' has been rejected. Reason: reason"
        match = value.match(/^Your item '(.+)' has been rejected\. Reason: (.+)$/);
        if (match) return `تم رفض منتجك '${match[1]}'. السبب: ${match[2]}`;

        // ID Verification
        if (value.includes('Your identity verification request has been approved')) return 'تمت الموافقة على طلب توثيق هويتك. أنت الآن عضو موثق.';
        
        match = value.match(/^Your identity verification request was rejected\. Notes: (.+)$/);
        if (match) return `تم رفض طلب توثيق هويتك. ملاحظات: ${match[1]}`;

        return this.translate.instant(value);
    }
  }
}
