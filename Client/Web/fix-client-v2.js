const fs = require('fs');
const path = require('path');

const clientPath = path.join(__dirname, 'src/app/core/api/api-client.ts');
let content = fs.readFileSync(clientPath, 'utf8');

console.log('Starting refactor of api-client.ts...');

const initialLength = content.length;

// Remove all NSwag generated wrapper classes and interfaces for ApiResponseOf...
content = content.replace(/export class ApiResponseOf[a-zA-Z0-9_]+(?: implements IApiResponseOf[a-zA-Z0-9_]+)? \{[\s\S]*?\n\}/g, '');
content = content.replace(/export interface IApiResponseOf[a-zA-Z0-9_]+ \{[\s\S]*?\n\}/g, '');

// Prevent TS1477: static methods shouldn't have generic types
content = content.replace(/ApiResponseOf[a-zA-Z0-9_]+\.fromJS/g, 'ApiResponse.fromJS');

// Special cases for Lists (e.g., ApiResponseOfListOfItemListDto -> ApiResponse<ItemListDto[]>)
content = content.replace(/ApiResponseOfListOf([a-zA-Z0-9_]+)/g, 'ApiResponse<$1[]>');

// Special case for Object -> null
content = content.replace(/ApiResponseOfObject/g, 'ApiResponse<null>');

// General case
content = content.replace(/ApiResponseOf([a-zA-Z0-9_]+)/g, 'ApiResponse<$1>');

// Patch throwException to return parsed results as success instead of throwing
const throwExceptionPatch = `function throwException(message: string, status: number, response: string, headers: { [key: string]: any; }, result?: any): Observable<any> {
    if (result !== null && result !== undefined)
        return _observableOf(result);
    return _observableThrow(new ApiException(message, status, response, headers, result));
}

function blobToText(blob: any): Observable<string> {`;

content = content.replace(/function throwException\([\s\S]*?\}\r?\n\r?\nfunction blobToText\(blob: any\): Observable<string> \{/, throwExceptionPatch);

const finalLength = content.length;
fs.writeFileSync(clientPath, content, 'utf8');

console.log(`Successfully refactored api-client.ts. Length reduced by ${initialLength - finalLength} characters.`);

