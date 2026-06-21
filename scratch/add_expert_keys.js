const fs = require('fs');

function addKeys(file, key, value) {
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!data.expert) data.expert = {};
  if (!data.expert.history) data.expert.history = {};
  data.expert.history[key] = value;
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
  console.log(`Updated ${file}`);
}

addKeys('Client/Expert/public/i18n/en.json', 'receive_renting', "Receive the renting");
addKeys('Client/Expert/public/i18n/ar.json', 'receive_renting', "استلام الإيجار");
