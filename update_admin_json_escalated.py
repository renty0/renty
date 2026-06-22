import json

def update_file(path, lang):
    with open(path, 'r') as f:
        data = json.load(f)
        
    if lang == 'en':
        data['SUPPORT']['TICKETS']['STATUS_TYPES']['ESCALATED'] = "Escalated"
    else:
        data['SUPPORT']['TICKETS']['STATUS_TYPES']['ESCALATED'] = "تم التصعيد"
        
    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

update_file('Client/Admin/public/i18n/en.json', 'en')
update_file('Client/Admin/public/i18n/ar.json', 'ar')
