enum WorkerErrorCodes {
  setUpWorker,
  cleanExpiredData,
  updateWokerImage,
  deleteWorkerImage,
  setupFocusedDay,
  removeTimeFromDay,
  addTimeToDay,
  saveWorkTime,
  removeTimeFromVacations,
  addTimeToVacations,
  addDayToVacations,
  removeDayFromVacations,
  saveVacations,
  changeDaysToAllowBookings,
  addTreatment,
  removeTreatment,
  changeOnHoldMinutes,
  cahngeDaysToCleanExpired,
  setFocusedDate,
  setVacations,
  setWorkTime,
  cahngeStatusForBooking,
  updateFcmIfNeeded,
  updateNotifyWhenGettingBooking,
  updateAllowNotLoggedInToOrder,
  removeBreak,
  addBreak,
  updateDurationToCleanExpiredIfNeeded,
  pauseListening,
  pauseAllActivateListenings,
  cancelListening,
  resumeListening,
  setDeleteWorkerData,
  setBookingNote,
  setBreakNote,
  makeListener,
  updateShowSceduleColors,
  deleteBookingsOfDayBefore,
  updateNotifyWhenGettingBookingIfNeeded,
  updateOnHoldMinutesIfNeeded,
  updateNotifyOnWaitingListEvents,
  updateNotifyOnWaitingListEventsIfNeeded
}

Map<WorkerErrorCodes, int> workerCodeToInt = {
  WorkerErrorCodes.setUpWorker: 2001,
  WorkerErrorCodes.cleanExpiredData: 2002,
  WorkerErrorCodes.updateWokerImage: 2003,
  WorkerErrorCodes.deleteWorkerImage: 2004,
  WorkerErrorCodes.setupFocusedDay: 2005,
  WorkerErrorCodes.removeTimeFromDay: 2006,
  WorkerErrorCodes.addTimeToDay: 2007,
  WorkerErrorCodes.saveWorkTime: 2008,
  WorkerErrorCodes.removeTimeFromVacations: 2009,
  WorkerErrorCodes.addTimeToVacations: 2010,
  WorkerErrorCodes.addDayToVacations: 2011,
  WorkerErrorCodes.removeDayFromVacations: 2012,
  WorkerErrorCodes.saveVacations: 2013,
  WorkerErrorCodes.changeDaysToAllowBookings: 2014,
  WorkerErrorCodes.addTreatment: 2015,
  WorkerErrorCodes.removeTreatment: 2016,
  WorkerErrorCodes.changeOnHoldMinutes: 2017,
  WorkerErrorCodes.cahngeDaysToCleanExpired: 2018,
  WorkerErrorCodes.setFocusedDate: 2019,
  WorkerErrorCodes.setVacations: 2020,
  WorkerErrorCodes.setWorkTime: 2021,
  WorkerErrorCodes.cahngeStatusForBooking: 2022,
  WorkerErrorCodes.updateFcmIfNeeded: 2023,
  WorkerErrorCodes.updateNotifyWhenGettingBooking: 2024,
  WorkerErrorCodes.updateAllowNotLoggedInToOrder: 2025,
  WorkerErrorCodes.removeBreak: 2026,
  WorkerErrorCodes.addBreak: 2027,
  WorkerErrorCodes.updateDurationToCleanExpiredIfNeeded: 2028,
  WorkerErrorCodes.pauseListening: 2029,
  WorkerErrorCodes.pauseAllActivateListenings: 2030,
  WorkerErrorCodes.cancelListening: 2031,
  WorkerErrorCodes.resumeListening: 2032,
  WorkerErrorCodes.setBookingNote: 2023,
  WorkerErrorCodes.setBreakNote: 2024,
  WorkerErrorCodes.makeListener: 2025,
  WorkerErrorCodes.updateShowSceduleColors: 2026,
  WorkerErrorCodes.deleteBookingsOfDayBefore: 2027,
  WorkerErrorCodes.updateNotifyWhenGettingBookingIfNeeded: 2028,
  WorkerErrorCodes.updateOnHoldMinutesIfNeeded: 2029,
  WorkerErrorCodes.updateNotifyOnWaitingListEvents: 2030,
  WorkerErrorCodes.updateNotifyOnWaitingListEventsIfNeeded: 2031
};
