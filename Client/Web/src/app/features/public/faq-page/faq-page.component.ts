import { Component, inject, computed, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { LocalizationService } from '../../../core/services/localization.service';

interface FaqItem {
  id: string;
  category: string;
  questionAr: string;
  questionEn: string;
  answerAr: string;
  answerEn: string;
}

@Component({
  selector: 'app-faq-page',
  standalone: true,
  imports: [CommonModule, TranslateModule, MatIconModule, RouterModule, FormsModule],
  templateUrl: './faq-page.component.html',
  styleUrl: './faq-page.component.scss'
})
export class FaqPageComponent {
  private localization = inject(LocalizationService);

  get lang() {
    return this.localization.language();
  }

  get isArabic() {
    return this.lang === 'ar';
  }

  selectedCategory = signal<string>('all');
  searchQuery = signal<string>('');
  openItems = signal<Set<string>>(new Set<string>());

  categories = [
    { id: 'all', labelAr: 'الكل', labelEn: 'All', translateKey: 'catAll' },
    { id: 'register', labelAr: 'البدء والتسجيل', labelEn: 'Getting Started', translateKey: 'catRegister' },
    { id: 'rental', labelAr: 'التأجير والحجز', labelEn: 'Renting & Booking', translateKey: 'catRental' },
    { id: 'payment', labelAr: 'الدفع والأسعار', labelEn: 'Payment & Pricing', translateKey: 'catPayment' },
    { id: 'experts', labelAr: 'الخبراء والجودة', labelEn: 'Experts & Quality', translateKey: 'catExperts' },
    { id: 'disputes', labelAr: 'النزاعات والمشكلات', labelEn: 'Disputes & Issues', translateKey: 'catDisputes' },
    { id: 'account', labelAr: 'الحساب والملف الشخصي', labelEn: 'Account & Profile', translateKey: 'catAccount' }
  ];

  faqs: FaqItem[] = [
    // Register
    {
      id: 'reg1',
      category: 'register',
      questionAr: 'كيف أسجّل في رنتي؟',
      questionEn: 'How do I register on Renty?',
      answerAr: 'أنشئ حسابًا مجانيًا بإدخال اسمك، بريدك الإلكتروني، وكلمة مرور. ستتلقّى رسالة تفعيل على بريدك، ثم اختر نوع حسابك: <strong>مستأجر</strong> أو <strong>مالك</strong> أو <strong>عضو</strong> (كلاهما).',
      answerEn: 'Create a free account by entering your name, email, and password. You will receive an activation email, then choose your account type: <strong>Renter</strong>, <strong>Owner</strong>, or <strong>Member</strong> (both).'
    },
    {
      id: 'reg2',
      category: 'register',
      questionAr: 'ما الفرق بين المالك والمستأجر والعضو؟',
      questionEn: 'What is the difference between Owner, Renter, and Member?',
      answerAr: '<strong>المالك</strong> يعرض معداته للتأجير ويكسب دخلًا إضافيًا.<br><strong>المستأجر</strong> يتصفّح المعدات المتاحة ويستأجرها.<br><strong>العضو</strong> لديه صلاحيات كليهما — يمكنه التأجير والاستئجار في آنٍ واحد.',
      answerEn: '<strong>Owner</strong> lists their equipment for rent and earns extra income.<br><strong>Renter</strong> browses and rents available equipment.<br><strong>Member</strong> has the privileges of both — they can rent and list equipment at the same time.'
    },
    {
      id: 'reg3',
      category: 'register',
      questionAr: 'هل التسجيل مجاني؟',
      questionEn: 'Is registration free?',
      answerAr: 'نعم، التسجيل وإنشاء الحساب مجاني تمامًا. رنتي تحصل على عمولة بسيطة <strong>عند اكتمال عملية التأجير فقط</strong> — لا رسوم شهرية أو اشتراكات.',
      answerEn: 'Yes, registration and account creation are completely free. Renty takes a small commission <strong>only when a rental transaction is completed</strong> — no monthly fees or subscriptions.'
    },
    {
      id: 'reg4',
      category: 'register',
      questionAr: 'ما الحد الأدنى للسن للاستخدام؟',
      questionEn: 'What is the minimum age for using the platform?',
      answerAr: 'يجب أن يكون عمرك <strong>18 عامًا</strong> على الأقل لاستخدام منصة رنتي. الحسابات التي تخالف هذا الشرط تُحذف فور اكتشافها.',
      answerEn: 'You must be at least <strong>18 years old</strong> to use the Renty platform. Accounts violating this policy will be terminated immediately upon discovery.'
    },
    {
      id: 'reg5',
      category: 'register',
      questionAr: 'هل يمكنني استخدام رنتي في أي محافظة مصرية؟',
      questionEn: 'Can I use Renty in any Egyptian governorate?',
      answerAr: 'نعم، رنتي متاحة في جميع المحافظات الـ27 في مصر. الكثافة الأعلى حاليًا في <strong>القاهرة، الجيزة، الإسكندرية، والبحر الأحمر</strong> — وتتوسع المنصة باستمرار.',
      answerEn: 'Yes, Renty is available in all 27 governorates in Egypt. The highest density currently is in <strong>Cairo, Giza, Alexandria, and the Red Sea</strong> — and the platform is expanding constantly.'
    },
    // Rental
    {
      id: 'rent1',
      category: 'rental',
      questionAr: 'كيف تسير عملية الإيجار خطوة بخطوة؟',
      questionEn: 'How does the renting process work step-by-step?',
      answerAr: '<ol><li>ابحث عن المعدة المناسبة وتصفّح الخيارات.</li><li>اختر تواريخ الإيجار وراجع الأسعار والتفاصيل.</li><li>أرسل طلب الإيجار للمالك.</li><li>يوافق المالك على الطلب خلال 48 ساعة.</li><li>ادفع بأمان عبر المنصة.</li><li>استلم المعدة (توصيل أو استلام مباشر حسب الاتفاق).</li><li>استخدم المعدة وأرجعها في الموعد المحدد.</li><li>قيّم التجربة وساعد المجتمع!</li></ol>',
      answerEn: '<ol><li>Search for the right equipment and browse options.</li><li>Select rental dates and review pricing and details.</li><li>Send the rental request to the owner.</li><li>Owner approves the request within 48 hours.</li><li>Pay securely on the platform.</li><li>Receive the equipment (delivery or pickup as agreed).</li><li>Use the equipment and return it on time.</li><li>Rate your experience to help the community!</li></ol>'
    },
    {
      id: 'rent2',
      category: 'rental',
      questionAr: 'ماذا يحدث إذا لم يردّ المالك على طلبي؟',
      questionEn: 'What happens if the owner does not reply to my request?',
      answerAr: 'إذا لم يردّ المالك خلال <strong>48 ساعة</strong> من إرسال الطلب، يُلغى الطلب تلقائيًا ويُردّ إليك المبلغ المحجوز كاملًا دون أي خصومات.',
      answerEn: 'If the owner does not respond within <strong>48 hours</strong>, the request is automatically cancelled and the reserved amount is fully refunded to you without any deductions.'
    },
    {
      id: 'rent3',
      category: 'rental',
      questionAr: 'هل يمكنني تمديد فترة الإيجار؟',
      questionEn: 'Can I extend the rental period?',
      answerAr: 'نعم! أرسل طلب تمديد من صفحة تفاصيل الإيجار. عند موافقة المالك، يُحسب فرق السعر تلقائيًا ويُضاف للدفع، شريطة ألّا يكون هناك حجز آخر على نفس المعدة في الفترة المطلوبة.',
      answerEn: 'Yes! Send an extension request from the rental details page. Once the owner approves, the price difference is calculated automatically and added to the payment, provided there is no other booking for the same equipment during that period.'
    },
    {
      id: 'rent4',
      category: 'rental',
      questionAr: 'هل يمكنني إلغاء الحجز؟',
      questionEn: 'Can I cancel the booking?',
      answerAr: 'نعم، يمكن الإلغاء وفق سياسة الإلغاء التي اختارها المالك عند نشر المعدة: <strong>مرنة</strong> (استرداد كامل قبل 24 ساعة)، <strong>معتدلة</strong> (استرداد جزئي)، أو <strong>صارمة</strong>. راجع صفحة الشروط والأحكام للتفاصيل الكاملة.',
      answerEn: 'Yes, cancellations can be made according to the cancellation policy chosen by the owner: <strong>Flexible</strong> (full refund up to 24 hours prior), <strong>Moderate</strong> (partial refund), or <strong>Strict</strong>. Review the Terms page for details.'
    },
    {
      id: 'rent5',
      category: 'rental',
      questionAr: 'ما هو مبلغ التأمين (الوديعة)؟',
      questionEn: 'What is the security deposit?',
      answerAr: 'يحدد المالك مبلغ التأمين لكل منتج بناءً على قيمته. يُحجز المبلغ عند الدفع ويُردّ خلال <strong>5 أيام عمل</strong> بعد تأكيد إرجاع المعدة بحالة جيدة.',
      answerEn: 'The owner determines the security deposit amount for each product based on its value. The amount is held during payment and returned within <strong>5 business days</strong> after confirming the equipment is returned in good condition.'
    },
    // Payment
    {
      id: 'pay1',
      category: 'payment',
      questionAr: 'ما طرق الدفع المتاحة؟',
      questionEn: 'What payment methods are available?',
      answerAr: 'ندعم طرق الدفع الأكثر شيوعًا في مصر:<br>💚 <strong>Vodafone Cash</strong> &nbsp;|&nbsp; 🟠 <strong>Fawry</strong> &nbsp;|&nbsp; 🔵 <strong>Paymob</strong><br>💳 <strong>بطاقات الائتمان والخصم</strong> &nbsp;|&nbsp; 🏦 <strong>التحويل البنكي</strong>',
      answerEn: 'We support the most popular payment methods in Egypt:<br>💚 <strong>Vodafone Cash</strong> &nbsp;|&nbsp; 🟠 <strong>Fawry</strong> &nbsp;|&nbsp; 🔵 <strong>Paymob</strong><br>💳 <strong>Credit & Debit Cards</strong> &nbsp;|&nbsp; 🏦 <strong>Bank Transfer</strong>'
    },
    {
      id: 'pay2',
      category: 'payment',
      questionAr: 'متى يُخصم المبلغ من حسابي؟',
      questionEn: 'When is the amount deducted from my account?',
      answerAr: 'يُحجز المبلغ <strong>فور موافقتك على الحجز</strong>، لكنه لا يُعوَّل للمالك إلا بعد تأكيد استلام المعدة وبدء فترة الإيجار فعليًا — لضمان حقوق الطرفين.',
      answerEn: 'The amount is held <strong>as soon as you approve the booking</strong>, but it is not transferred to the owner until you confirm receipt of the equipment and the rental period actually starts — ensuring the rights of both parties.'
    },
    {
      id: 'pay3',
      category: 'payment',
      questionAr: 'هل توجد رسوم خفية؟',
      questionEn: 'Are there any hidden fees?',
      answerAr: 'لا على الإطلاق. جميع التكاليف تظهر بوضوح <strong>قبل تأكيد الحجز</strong>: سعر الإيجار، مبلغ التأمين، رسوم الخبير (إن طُلبت)، ورسوم الخدمة. ما تراه هو ما تدفعه.',
      answerEn: 'Not at all. All costs are shown clearly <strong>before booking confirmation</strong>: rental price, security deposit, expert fees (if requested), and service fees. What you see is what you pay.'
    },
    {
      id: 'pay4',
      category: 'payment',
      questionAr: 'كيف يحصل المالك على أمواله؟',
      questionEn: 'How does the owner receive their money?',
      answerAr: 'بعد تأكيد اكتمال الإيجار وإرجاع المعدة بحالة جيدة، تُحوَّل الأموال للمالك خلال <strong>3-5 أيام عمل</strong> عبر طريقة الدفع المسجَّلة في حسابه.',
      answerEn: 'After confirming the rental completion and equipment return in good condition, funds are transferred to the owner within <strong>3-5 business days</strong> via their registered payment method.'
    },
    {
      id: 'pay5',
      category: 'payment',
      questionAr: 'هل الدفع آمن؟',
      questionEn: 'Is payment secure?',
      answerAr: 'نعم تمامًا. جميع المعاملات مشفّرة بتقنية SSL ومعالَجة عبر بوابات دفع معتمدة. <strong>لا نحتفظ ببيانات بطاقاتك</strong> على خوادمنا.',
      answerEn: 'Yes, absolutely. All transactions are SSL encrypted and processed through certified payment gateways. <strong>We do not store your card details</strong> on our servers.'
    },
    // Experts
    {
      id: 'exp1',
      category: 'experts',
      questionAr: 'من هم خبراء رنتي؟',
      questionEn: 'Who are Renty experts?',
      answerAr: 'خبراء رنتي متخصصون <strong>معتمدون من قِبَل المنصة</strong>، لديهم خبرة موثَّقة في تقييم المعدات الرياضية (بادل، رياضات مائية، دراجات، تخييم وغيرها). يفحصون المعدة قبل وبعد كل إيجار لضمان مطابقتها للوصف وسلامتها.',
      answerEn: 'Renty experts are specialists <strong>certified by the platform</strong>, having documented experience in evaluating sports equipment (padel, water sports, cycling, camping, etc.). They inspect the equipment before and after each rental to ensure safety and description matching.'
    },
    {
      id: 'exp2',
      category: 'experts',
      questionAr: 'هل فحص الخبير إلزامي؟',
      questionEn: 'Is expert inspection mandatory?',
      answerAr: 'لا، ليس إلزاميًا، لكنّه <strong>مُوصى به بشدة</strong> خاصةً للمعدات ذات القيمة المرتفعة كمعدات الغوص أو الكايتسرفينج. الفحص يحمي كلا الطرفين ويُقلّل احتمالية النزاعات.',
      answerEn: 'No, it\'s not mandatory, but it is <strong>highly recommended</strong>, especially for high-value equipment like diving or kitesurfing gear. The inspection protects both parties and reduces disputes.'
    },
    {
      id: 'exp3',
      category: 'experts',
      questionAr: 'من يتحمّل تكلفة فحص الخبير؟',
      questionEn: 'Who bears the cost of the expert inspection?',
      answerAr: 'تُوزَّع التكلفة وفق سياسة المنصة المحدَّثة، وتظهر <strong>بوضوح قبل تأكيد الحجز</strong> ضمن تفاصيل التكاليف حتى لا تُفاجَأ.',
      answerEn: 'The cost is distributed according to platform policy, and appears <strong>clearly before booking confirmation</strong> under the cost breakdown.'
    },
    {
      id: 'exp4',
      category: 'experts',
      questionAr: 'ماذا يحدث إذا رفض الخبير المعدة؟',
      questionEn: 'What happens if the expert rejects the equipment?',
      answerAr: 'إذا رفض الخبير المعدة لعدم مطابقتها للمعايير أو الوصف، يُلغى الإيجار ويُردّ للمستأجر مبلغه <strong>كاملًا</strong>. يتلقّى المالك تقرير الخبير المفصَّل لمعالجة المشكلة قبل إعادة نشر المعدة.',
      answerEn: 'If the expert rejects the equipment for not meeting standards or description, the rental is cancelled and the renter is fully refunded. The owner receives a detailed report to address the issue before relisting.'
    },
    // Disputes
    {
      id: 'disp1',
      category: 'disputes',
      questionAr: 'ماذا أفعل إذا وصلتني المعدة تالفة أو مختلفة عن الوصف؟',
      questionEn: 'What do I do if the equipment arrives damaged or different from description?',
      answerAr: 'افتح نزاعًا من صفحة تفاصيل الإيجار خلال <strong>7 أيام</strong> من الاستلام، وارفق صورًا وشرحًا واضحًا. سيراجع فريق الدعم القضية ويصدر قرارًا خلال <strong>5 أيام عمل</strong>.',
      answerEn: 'Open a dispute from the rental details page within <strong>7 days</strong> of receipt, attaching photos and a clear explanation. Support will review the case and issue a decision within <strong>5 business days</strong>.'
    },
    {
      id: 'disp2',
      category: 'disputes',
      questionAr: 'ماذا يحدث إذا تأخّر المستأجر في إرجاع المعدة؟',
      questionEn: 'What happens if the renter returns the equipment late?',
      answerAr: 'تُطبَّق <strong>رسوم تأخير يومية</strong> يحددها المالك مسبقًا وتظهر في صفحة المنتج. إذا تجاوز التأخير حدًا معينًا يحدده النظام، يمكن للمالك رفع تقرير رسمي عبر المنصة.',
      answerEn: 'Daily late fees determined by the owner apply. If the delay exceeds a limit, the owner can file a formal report through the platform.'
    },
    {
      id: 'disp3',
      category: 'disputes',
      questionAr: 'كيف يُحسم النزاع بين المالك والمستأجر؟',
      questionEn: 'How is a dispute resolved between owner and renter?',
      answerAr: 'يُرسل كلا الطرفين حججهما وأدلتهما (صور، رسائل، تقارير الخبير). يراجع فريق دعم رنتي جميع المعطيات ويتخذ قرارًا <strong>ملزمًا وعادلًا</strong> خلال 5 أيام عمل. قرار المنصة نهائي وفق الشروط والأحكام.',
      answerEn: 'Both parties submit arguments and evidence (photos, messages, expert reports). Renty support reviews the facts and makes a <strong>binding, fair decision</strong> within 5 business days. The decision is final.'
    },
    {
      id: 'disp4',
      category: 'disputes',
      questionAr: 'هل يمكنني الإبلاغ عن منتج مزيّف أو مضلّل؟',
      questionEn: 'Can I report a fake or misleading product?',
      answerAr: 'نعم. في صفحة تفاصيل المنتج، اضغط زر <strong>"إبلاغ"</strong> واختر السبب المناسب. عند وصول <strong>3 بلاغات</strong> على منتج واحد، تُجرى مراجعة فورية من فريق الإدارة.',
      answerEn: 'Yes. On the product details page, click <strong>"Report"</strong> and choose the reason. If 3 reports are received for the same product, it will be immediately reviewed by management.'
    },
    // Account
    {
      id: 'acc1',
      category: 'account',
      questionAr: 'كيف أُعدّل بيانات حسابي؟',
      questionEn: 'How do I edit my account details?',
      answerAr: 'اذهب إلى <strong>الملف الشخصي ← تعديل المعلومات الشخصية</strong>. يمكنك تغيير الاسم، الصورة، رقم الهاتف، والمدينة. التغييرات تُطبَّق فورًا.',
      answerEn: 'Go to <strong>Profile -> Edit Personal Info</strong>. You can update your name, photo, phone number, and city. Changes apply immediately.'
    },
    {
      id: 'acc2',
      category: 'account',
      questionAr: 'كيف أحذف حسابي؟',
      questionEn: 'How do I delete my account?',
      answerAr: 'من <strong>الإعدادات ← حذف الحساب</strong>. سيتم حذف بياناتك نهائيًا خلال <strong>90 يومًا</strong> وفق سياسة الخصوصية. ملاحظة: لا يمكن حذف الحساب إذا كان لديك إيجارات نشطة أو مبالغ معلّقة.',
      answerEn: 'From <strong>Settings -> Delete Account</strong>. Your data will be permanently deleted within 90 days according to the privacy policy. Note: You cannot delete the account with active rentals or pending payments.'
    },
    {
      id: 'acc3',
      category: 'account',
      questionAr: 'نسيت كلمة المرور، ماذا أفعل؟',
      questionEn: 'I forgot my password, what should I do?',
      answerAr: 'من صفحة تسجيل الدخول، اضغط <strong>"نسيت كلمة المرور؟"</strong>، أدخل بريدك الإلكتروني وستصلك رسالة فيها رابط لإعادة التعيين. انتبه: <strong>تنتهي صلاحية الرابط بعد ساعة</strong> واحدة.',
      answerEn: 'From the login page, click <strong>"Forgot Password?"</strong>, enter your email, and a reset link will be sent. Note: <strong>The link expires after one hour</strong>.'
    },
    {
      id: 'acc4',
      category: 'account',
      questionAr: 'هل يمكنني امتلاك حسابين؟',
      questionEn: 'Can I have two accounts?',
      answerAr: 'لا. يُسمح بـ<strong>حساب واحد فقط</strong> لكل شخص. إنشاء حسابات متعددة يُعدّ مخالفة صريحة للشروط والأحكام ويؤدي إلى إيقاف جميع الحسابات المرتبطة.',
      answerEn: 'No. Only <strong>one account</strong> is allowed per person. Creating multiple accounts is a violation and leads to suspending all associated accounts.'
    }
  ];

  filteredFaqs = computed(() => {
    const cat = this.selectedCategory();
    const query = this.searchQuery().trim().toLowerCase();

    return this.faqs.filter(item => {
      // Category filter
      if (cat !== 'all' && item.category !== cat) {
        return false;
      }
      // Search query filter
      if (query) {
        const text = `${item.questionAr} ${item.questionEn} ${item.answerAr} ${item.answerEn}`.toLowerCase();
        return text.includes(query);
      }
      return true;
    });
  });

  filteredCategories = computed(() => {
    // If searching, we show all categories that have matching items
    const query = this.searchQuery().trim().toLowerCase();
    if (!query) return this.categories;

    return this.categories;
  });

  getGroupedFaqs() {
    const faqs = this.filteredFaqs();
    const groups: { [key: string]: FaqItem[] } = {};

    // Group items by category to keep headings
    faqs.forEach(item => {
      if (!groups[item.category]) {
        groups[item.category] = [];
      }
      groups[item.category].push(item);
    });

    return groups;
  }

  getCategoryLabel(categoryId: string): string {
    const cat = this.categories.find(c => c.id === categoryId);
    if (!cat) return '';
    return this.isArabic ? cat.labelAr : cat.labelEn;
  }

  toggleItem(itemId: string) {
    const current = new Set(this.openItems());
    if (current.has(itemId)) {
      current.delete(itemId);
    } else {
      current.add(itemId);
    }
    this.openItems.set(current);
  }

  isOpen(itemId: string): boolean {
    return this.openItems().has(itemId);
  }

  selectCategory(category: string) {
    this.selectedCategory.set(category);
    // When changing category, clear search to avoid confusion, or keep it. Let's clear search.
    this.searchQuery.set('');
  }
}
