const fs = require('fs');
const file = 'Client/Expert/public/i18n/ar.json';
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
data.expert.history.receive_renting = "التسليم للمستأجر";
fs.writeFileSync(file, JSON.stringify(data, null, 2));
console.log(`Updated ${file}`);
