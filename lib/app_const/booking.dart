enum BookingStatuses {
  waiting,
  approved,
}

const Map<BookingStatuses, String> bookingsMassage = {
  BookingStatuses.waiting: "waiting",
  BookingStatuses.approved: "confirmed",
};

const Map<String, BookingStatuses> bookingsMassageKeys = {
  "waiting": BookingStatuses.waiting,
  "confirmed": BookingStatuses.approved,
};
