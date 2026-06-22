import json

def update_file(path, lang):
    with open(path, 'r') as f:
        data = json.load(f)
        
    if 'ADMIN' not in data:
        data['ADMIN'] = {}
        
    if 'ITEMS' not in data['ADMIN']:
        data['ADMIN']['ITEMS'] = {}
        
    if 'IDS' not in data['ADMIN']:
        data['ADMIN']['IDS'] = {}

    if lang == 'en':
        data['ADMIN']['ITEMS'].update({
            "APPROVAL_QUEUE": "Items Approval Queue",
            "APPROVE_SELECTED": "Approve Selected",
            "REJECT_SELECTED": "Reject Selected",
            "ITEM_TITLE": "Item Title",
            "OWNER": "Owner",
            "CATEGORY": "Category",
            "PRICE_PER_DAY": "Price / Day",
            "DATE_SUBMITTED": "Date Submitted",
            "STATUS": "Status",
            "PENDING": "Pending",
            "ACTIONS": "Actions",
            "NO_ITEMS_PENDING": "No items pending approval."
        })
        
        data['ADMIN']['IDS'].update({
            "VERIFICATION_QUEUE": "ID Verification Queue",
            "VERIFY_SELECTED": "Verify Selected",
            "REJECT_SELECTED": "Reject Selected",
            "USER": "User",
            "FRONT_ID": "Front ID",
            "BACK_ID": "Back ID",
            "SUBMISSION_DATE": "Submission Date",
            "STATUS": "Status",
            "PENDING_REVIEW": "Pending Review",
            "ACTIONS": "Actions",
            "NO_VERIFICATIONS_PENDING": "No ID verifications pending."
        })
    else:
        data['ADMIN']['ITEMS'].update({
            "APPROVAL_QUEUE": "قائمة انتظار الموافقة على العناصر",
            "APPROVE_SELECTED": "الموافقة على المحدد",
            "REJECT_SELECTED": "رفض المحدد",
            "ITEM_TITLE": "عنوان العنصر",
            "OWNER": "المالك",
            "CATEGORY": "الفئة",
            "PRICE_PER_DAY": "السعر / اليوم",
            "DATE_SUBMITTED": "تاريخ التقديم",
            "STATUS": "الحالة",
            "PENDING": "قيد الانتظار",
            "ACTIONS": "إجراءات",
            "NO_ITEMS_PENDING": "لا توجد عناصر في انتظار الموافقة."
        })
        
        data['ADMIN']['IDS'].update({
            "VERIFICATION_QUEUE": "قائمة انتظار التحقق من الهوية",
            "VERIFY_SELECTED": "التحقق من المحدد",
            "REJECT_SELECTED": "رفض المحدد",
            "USER": "المستخدم",
            "FRONT_ID": "الهوية الأمامية",
            "BACK_ID": "الهوية الخلفية",
            "SUBMISSION_DATE": "تاريخ التقديم",
            "STATUS": "الحالة",
            "PENDING_REVIEW": "في انتظار المراجعة",
            "ACTIONS": "إجراءات",
            "NO_VERIFICATIONS_PENDING": "لا توجد عمليات تحقق من الهوية معلقة."
        })
        
    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

update_file('Client/Admin/public/i18n/en.json', 'en')
update_file('Client/Admin/public/i18n/ar.json', 'ar')
