import json
with open('Client/Admin/public/i18n/ar.json', 'r') as f:
    data = json.load(f)

if 'ADMIN' not in data:
    data['ADMIN'] = {}

data['ADMIN']['DISPUTES'] = {
    "OPEN_DISPUTES": "النزاعات المفتوحة",
    "RESOLVED_DISPUTES": "النزاعات المحلولة",
    "AVAILABLE_DISPUTES": "النزاعات المتاحة",
    "MY_DISPUTES": "نزاعاتي",
    "RENTAL_ID": "رقم الإيجار",
    "ASSIGN_TO_ME": "تعيين لي",
    "RESOLVE_FINANCIALS": "تسوية مالية",
    "RESOLUTION_DATE": "تاريخ الحل",
    "RESOLVED_BY": "تم الحل بواسطة",
    "FINAL_MESSAGE": "الرسالة النهائية",
    "NO_AVAILABLE": "لا توجد نزاعات متاحة.",
    "NO_ASSIGNED": "ليس لديك نزاعات معينة.",
    "NO_RESOLVED": "لا توجد نزاعات محلولة.",
    "CLOSED_BY_ADMIN": "مغلق بواسطة المشرف"
}

if 'SUPPORT' not in data:
    data['SUPPORT'] = {}
if 'TICKETS' not in data['SUPPORT']:
    data['SUPPORT']['TICKETS'] = {}

data['SUPPORT']['TICKETS'].update({
    "TICKET_ID": "رقم التذكرة",
    "REPORTED_BY": "مُبلغ بواسطة",
    "STATUS": "الحالة",
    "CREATED_AT": "تاريخ الإنشاء",
    "ACTIONS": "إجراءات",
    "STATUS_TYPES": {
        "OPEN": "مفتوح",
        "IN_PROGRESS": "قيد التقدم",
        "RESOLVED": "تم الحل",
        "CLOSED": "مغلق",
        "AWAITINGSUPPORT": "في انتظار الدعم",
        "AWAITINGCUSTOMER": "في انتظار العميل"
    }
})

with open('Client/Admin/public/i18n/ar.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
