const http = require('http');

const loginData = JSON.stringify({
  email: 'kboss2073@gmail.com',
  password: 'Password123!'
});

const req = http.request({
  hostname: '127.0.0.1',
  port: 5106,
  path: '/api/v1/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': loginData.length
  }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log(data);
  });
});
req.write(loginData);
req.end();
