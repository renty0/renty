const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');
const AdmZip = require('adm-zip');

const swaggerUrl = 'http://localhost:5106/swagger/v1/swagger.json';
const apiUrl = 'https://api.openapi-generator.tech/api/gen/clients/dart';
const outputDir = path.join(__dirname, 'lib', 'api');

console.log('Fetching Swagger JSON from', swaggerUrl);

http.get(swaggerUrl, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        let spec;
        try {
            spec = JSON.parse(data);
        } catch (e) {
            console.error('Failed to parse Swagger JSON:', e);
            process.exit(1);
        }

        console.log('Requesting Dart client generation from openapi-generator.tech...');

        const postData = JSON.stringify({
            spec: spec,
            options: {
                pubName: 'renty_api',
                pubVersion: '1.0.0',
                pubDescription: 'Auto-generated API client for Renty'
            }
        });

        const reqOptions = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = https.request(apiUrl, reqOptions, (res) => {
            let resData = '';
            res.on('data', chunk => resData += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    const result = JSON.parse(resData);
                    const link = result.link;
                    console.log('Download link received:', link);
                    downloadAndExtract(link);
                } else {
                    console.error('Failed to request generation. Status:', res.statusCode, resData);
                }
            });
        });

        req.on('error', (e) => {
            console.error('API request error:', e);
        });

        req.write(postData);
        req.end();
    });
}).on('error', (e) => {
    console.error('Failed to fetch swagger JSON. Is the backend running?');
    console.error(e);
});

function downloadAndExtract(url) {
    console.log('Downloading zip file...');
    const protocolHandler = url.startsWith('https') ? https : http;
    protocolHandler.get(url, (res) => {
        const zipPath = path.join(__dirname, 'api-client.zip');
        const file = fs.createWriteStream(zipPath);

        res.pipe(file);

        file.on('finish', () => {
            file.close(() => {
                console.log('Extracting zip file to', outputDir);
                try {
                    const zip = new AdmZip(zipPath);
                    const zipEntries = zip.getEntries();

                    // Clear existing
                    if (fs.existsSync(outputDir)) {
                        fs.rmSync(outputDir, { recursive: true, force: true });
                    }
                    fs.mkdirSync(outputDir, { recursive: true });

                    // Find common prefix (like 'dart-client/')
                    let rootDir = '';
                    if (zipEntries.length > 0) {
                        const firstEntry = zipEntries[0].entryName;
                        if (firstEntry.includes('/')) {
                            rootDir = firstEntry.split('/')[0] + '/';
                        }
                    }

                    // Extract specifically
                    zipEntries.forEach(entry => {
                        if (!entry.isDirectory) {
                            let entryName = entry.entryName;
                            // remove rootDir prefix if exists
                            if (rootDir && entryName.startsWith(rootDir)) {
                                entryName = entryName.substring(rootDir.length);
                            }

                            if (entryName) { // if not empty
                                const targetPath = path.join(outputDir, entryName);
                                const targetDir = path.dirname(targetPath);
                                if (!fs.existsSync(targetDir)) {
                                    fs.mkdirSync(targetDir, { recursive: true });
                                }
                                fs.writeFileSync(targetPath, entry.getData());
                            }
                        }
                    });

                    fs.unlinkSync(zipPath);
                    console.log('Successfully generated and extracted Dart API client into lib/api');
                } catch (e) {
                    console.error('Error extracting zip:', e);
                }
            });
        });
    }).on('error', (e) => {
        console.error('Error downloading zip:', e);
    });
}
