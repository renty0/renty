import json

def process_file(path):
    with open(path, 'r') as f:
        data = json.load(f)
        
    projects = data.get('projects', {})
    for proj_name, proj_data in projects.items():
        targets = proj_data.get('architect', {})
        for target_name, target_data in targets.items():
            if 'options' in target_data and 'polyfills' in target_data['options']:
                polyfills = target_data['options']['polyfills']
                if isinstance(polyfills, list):
                    target_data['options']['polyfills'] = [p for p in polyfills if p != 'zone.js' and p != 'zone.js/testing']
                    
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)

process_file('Client/Admin/angular.json')
process_file('Client/Expert/angular.json')
process_file('Client/Support/angular.json')
try:
    process_file('Client/SuperAdmin/angular.json')
except:
    pass
