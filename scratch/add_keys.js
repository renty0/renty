const fs = require('fs');

function addKeys(file, keys) {
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  Object.assign(data.rentals.delivery, keys);
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
  console.log(`Updated ${file}`);
}

addKeys('Client/Web/public/i18n/en.json', {
  receive_from_expert_title: "The item is ready at the expert hub. How would you like to receive it?",
  pickup_in_person: "Pick up in person",
  pickup_in_person_desc: "Go to the expert hub to pick up the item.",
  use_delivery_service: "Use Delivery Service",
  use_delivery_service_desc: "An agent will pick it up and deliver it to you. (+EGP 25 fee)",
  confirm_selection: "Confirm Selection"
});

addKeys('Client/Web/public/i18n/ar.json', {
  receive_from_expert_title: "المنتج جاهز في مركز الخبراء. كيف تفضل استلامه؟",
  pickup_in_person: "استلام شخصي",
  pickup_in_person_desc: "اذهب إلى مركز الخبراء لاستلام المنتج بنفسك.",
  use_delivery_service: "استخدام خدمة توصيل",
  use_delivery_service_desc: "سيقوم مندوب باستلامه وتوصيله إليك. (+25 جنيه رسوم)",
  confirm_selection: "تأكيد الاختيار"
});
