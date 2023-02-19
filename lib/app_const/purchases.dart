/// This file is saving the app purchases
/// Example: save the purchaces level (advance / basic ), limitations

enum BuisnessLimitations {
  bookingCount,
  changingPhotos,
  storyPhotos,
  products,
  workers,
  expiredDataDeleteHeighsetDays,
  expiredDataDeleteLowestDays,
}

Map<BuisnessLimitations, String> limitationToStr = {
  BuisnessLimitations.bookingCount: "bookingCount",
  BuisnessLimitations.changingPhotos: "changingPhotos",
  BuisnessLimitations.storyPhotos: "storyPhotos",
  BuisnessLimitations.products: "products",
  BuisnessLimitations.expiredDataDeleteHeighsetDays:
      "expiredDataDeleteHeighsetDays",
  BuisnessLimitations.expiredDataDeleteLowestDays: "expiredDataDeleteLowestDays"
};

Map<String, BuisnessLimitations> limitationFromStr = {
  "expiredDataDeleteLowestDays":
      BuisnessLimitations.expiredDataDeleteLowestDays,
  "expiredDataDeleteHeighsetDays":
      BuisnessLimitations.expiredDataDeleteHeighsetDays,
  "bookingCount": BuisnessLimitations.bookingCount,
  "changingPhotos": BuisnessLimitations.changingPhotos,
  "storyPhotos": BuisnessLimitations.storyPhotos,
  "products": BuisnessLimitations.products
};

const limitsForBasicBusiness = {
  BuisnessLimitations.changingPhotos: 1,
  BuisnessLimitations.products: 0,
  BuisnessLimitations.storyPhotos: 3
};
const limitsForAdvancedBusiness = {
  BuisnessLimitations.changingPhotos: 3,
  BuisnessLimitations.products: 4,
  BuisnessLimitations.storyPhotos: 5
};

const limitsForTrialBusiness = {
  BuisnessLimitations.changingPhotos: 2,
  BuisnessLimitations.products: 1,
  BuisnessLimitations.storyPhotos: 2
};

// features advances business get and basic not
const advanceOrHigherSettings = [
  "upcomingOrder",
  "notifyOnNewCustomer",
  "workerData",
  "updates",
  "clientsNotifications",
  "acceptPayments",
  "getNotifyOnWaitingList"
];

enum SubType { basic, advanced, trial }

// optionals levels of the business
const subsLevels = {SubType.advanced: 1, SubType.basic: 2};
