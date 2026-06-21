const http = require('http');

const req = http.request({
  hostname: '127.0.0.1',
  port: 5106,
  path: '/api/v1/rentals',
  method: 'GET',
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log('GET Rentals:', data.substring(0, 500)));
});
req.on('error', e => console.error(e));
req.end();
