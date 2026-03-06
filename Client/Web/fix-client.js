const fs = require('fs');
const path = require('path');

const clientPath = path.join(__dirname, 'src/app/core/api/api-client.ts');
let content = fs.readFileSync(clientPath, 'utf8');

// 1. Remove the corrupted generic class if it exists at the bottom
content = content.replace(/E:\\Courses\\Work\\renty\\Client\\Web\\export class ApiResponse<T>[\s\S]*?}\n\nexport interface IApiResponse<T>[\s\S]*?}\r?\n?/g, '');
// Also remove if there's any correctly formatted generic definition at the bottom so we can append a fresh one
content = content.replace(/export class ApiResponse<T>[\s\S]*?}\n\nexport interface IApiResponse<T>[\s\S]*?}\r?\n?/g, '');


// 2. We need to parse line by line to remove class/interface definitions of ApiResponseOf...
let lines = content.split('\n');
let newLines = [];
let skipMode = false;

for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (!skipMode) {
        if (line.startsWith('export class ApiResponseOf') || line.startsWith('export interface IApiResponseOf')) {
            skipMode = true;
            continue; // skip this line
        }
    } else {
        if (line === '}' || line === '}\r') {
            skipMode = false;
        }
        continue; // skip lines while in skipMode
    }

    // If we are not skipping, we process the line for replacements
    let processedLine = line;

    // Special cases for Lists
    processedLine = processedLine.replace(/ApiResponseOfListOf([a-zA-Z0-9_]+)/g, 'ApiResponse<$1[]>');

    // Special case for Object -> null
    // wait, what about ApiResponseOfObject.fromJS(resultData400) ? 
    // It becomes ApiResponse.fromJS(resultData400)
    processedLine = processedLine.replace(/ApiResponseOfObject\.fromJS/g, 'ApiResponse.fromJS');
    // For type declarations:
    processedLine = processedLine.replace(/ApiResponseOfObject/g, 'ApiResponse<null>');

    // General case
    processedLine = processedLine.replace(/ApiResponseOf([a-zA-Z0-9_]+)\.fromJS/g, 'ApiResponse.fromJS');
    processedLine = processedLine.replace(/ApiResponseOf([a-zA-Z0-9_]+)/g, 'ApiResponse<$1>');

    newLines.push(processedLine);
}

// Ensure the new generic class and interface are added at the end
const genericDefinition = `
export class ApiResponse<T> {
    data?: T | undefined;
    error?: boolean;
    errorCode?: number[] | undefined;
    messages?: string[] | undefined;
    total?: number | undefined;
    page?: number | undefined;
    pages?: number | undefined;
    successCode?: number | undefined;

    constructor(data?: any) {
        if (data) {
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    (<any>this)[property] = (<any>data)[property];
                }
            }
        }
    }

    init(_data?: any) {
        if (_data) {
            this.data = _data['data'];
            this.error = _data['error'];
            if (Array.isArray(_data['errorCode'])) {
                this.errorCode = [] as any;
                for (let item of _data['errorCode']) {
                    this.errorCode!.push(item);
                }
            }
            if (Array.isArray(_data['messages'])) {
                this.messages = [] as any;
                for (let item of _data['messages']) {
                    this.messages!.push(item);
                }
            }
            this.total = _data['total'];
            this.page = _data['page'];
            this.pages = _data['pages'];
            this.successCode = _data['successCode'];
        }
    }

    static fromJS(data: any): ApiResponse<any> {
        data = typeof data === 'object' ? data : {};
        let result = new ApiResponse<any>();
        result.init(data);
        return result;
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data['data'] = this.data;
        data['error'] = this.error;
        if (Array.isArray(this.errorCode)) {
            data['errorCode'] = [];
            for (let item of this.errorCode) {
                data['errorCode'].push(item);
            }
        }
        if (Array.isArray(this.messages)) {
            data['messages'] = [];
            for (let item of this.messages) {
                data['messages'].push(item);
            }
        }
        data['total'] = this.total;
        data['page'] = this.page;
        data['pages'] = this.pages;
        data['successCode'] = this.successCode;
        return data;
    }
}

export interface IApiResponse<T> {
    data?: T | undefined;
    error?: boolean;
    errorCode?: number[] | undefined;
    messages?: string[] | undefined;
    total?: number | undefined;
    page?: number | undefined;
    pages?: number | undefined;
    successCode?: number | undefined;
}
`;

fs.writeFileSync(clientPath, newLines.join('\n') + genericDefinition, 'utf8');
console.log('Successfully refactored api-client.ts');
