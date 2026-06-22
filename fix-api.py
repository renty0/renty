import os

def fix_file(path):
    if not os.path.exists(path):
        return
    with open(path, 'r') as f:
        content = f.read()

    # If already fixed, skip
    if 'titleAr?: string;' in content:
        return

    # Add to class properties
    content = content.replace('    title?: string;\n    message?: string;\n    type?: string;',
                              '    title?: string;\n    message?: string;\n    titleAr?: string;\n    messageAr?: string;\n    type?: string;')

    # Add to init()
    content = content.replace('            this.title = _data["title"];\n            this.message = _data["message"];\n            this.type = _data["type"];',
                              '            this.title = _data["title"];\n            this.message = _data["message"];\n            this.titleAr = _data["titleAr"];\n            this.messageAr = _data["messageAr"];\n            this.type = _data["type"];')

    # Add to toJSON()
    content = content.replace('        data["title"] = this.title;\n        data["message"] = this.message;\n        data["type"] = this.type;',
                              '        data["title"] = this.title;\n        data["message"] = this.message;\n        data["titleAr"] = this.titleAr;\n        data["messageAr"] = this.messageAr;\n        data["type"] = this.type;')

    with open(path, 'w') as f:
        f.write(content)

base_dir = "Client"
for proj in ["Admin", "SuperAdmin", "Support", "Web"]:
    fix_file(f"{base_dir}/{proj}/src/app/core/api/api-client.ts")

