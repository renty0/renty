const fs = require('fs');

function addKeys(file, keys) {
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!data.expert) data.expert = {};
  if (!data.expert.history) data.expert.history = {};
  if (!data.expert.history.dialog) data.expert.history.dialog = {};
  Object.assign(data.expert.history.dialog, keys);
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
  console.log(`Updated ${file}`);
}

addKeys('Client/Expert/public/i18n/en.json', {
  "title": "Verify Transfer (Receiving / Handing Over)",
  "description": "Please enter the transfer code to confirm that the item has been physically transferred.",
  "cancel": "Cancel",
  "verify_btn": "Verify Code",
  "success": "Transfer verified successfully!",
  "placeholder": "EX: 123456"
});

addKeys('Client/Expert/public/i18n/ar.json', {
  "title": "تأكيد التسليم (استلام / تسليم)",
  "description": "يرجى إدخال رمز التأكيد لتأكيد نقل المنتج فعلياً.",
  "cancel": "إلغاء",
  "verify_btn": "تأكيد الرمز",
  "success": "تم تأكيد التسليم بنجاح!",
  "placeholder": "مثال: 123456"
});
