enum NotifySorts {
  waitingList,
  buisness,
}

const Map<NotifySorts, String> notifySortsToStr = {
  NotifySorts.waitingList: "whaitingList",
  NotifySorts.buisness: "shopNotification",
};

const Map<String, NotifySorts> notifySortsFromStr = {
  "whaitingList": NotifySorts.waitingList,
  "shopNotification": NotifySorts.buisness,
};
