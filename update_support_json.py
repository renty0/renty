import json

def update_file(path, lang):
    with open(path, 'r') as f:
        data = json.load(f)
    
    if 'support' not in data:
        data['support'] = {}
    if 'statuses' not in data['support']:
        data['support']['statuses'] = {}
        
    if lang == 'en':
        data['support']['statuses']['escalated'] = "Escalated"
    else:
        data['support']['statuses']['escalated'] = "تم التصعيد"
        
    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

update_file('Client/Support/public/i18n/en.json', 'en')
update_file('Client/Support/public/i18n/ar.json', 'ar')
