/// This file is saving the const firebase db
/// Example: save the endpoints of collections, docs , env

// envs
const productionKey = 'production';
const devKey = 'dev';
const shiloDevKey = 'shilo_dev';
const envKey = 'enviroments/$productionKey';

// fireStore endpoints
const usersCollection = "Users";
const anonymousCollection = "anonymousBookings";
const bookingsObjectsCollection = "BookingsObjects";
const dataDoc = "publicData";
const dataCollection = "PublicData";
const workersCollection = "Workers";
const bookingsCyollection = "Bookings";
const buisnessCollection = "Businesses";
const generalSettingsCollection = "generalSettings";
const englishPurchasesDoc = "englishPurchases";
const hebrewPurchasesDoc = "hebrewPurchases";
const buisnessesPreviewCollection = "BusinessesPreview";
const previewDoc = "preview";

// realTime db endpoints
const waitingListCollection = "WaitingListCollection";
const likesCollection = "LikesCollection";

// storage endpoints
const profilePhotosPath = "images/profiles";
const changingImagesPath = "images/changingImages";
const storyImagesPath = "images/stories";
const productsImagesPath = "images/productsImages";
const shopeIconsPath = "images/logos";

//--------------------------- db commands -------------------------------
enum ArrayCommands {
  add,
  remove,
}

enum NumericCommands { increment, decrement }

enum QueryCommands {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}
