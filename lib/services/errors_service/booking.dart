enum BookingErrorCodes {
  copyFromObject,
  setDate,
  setWorkerPhone,
  setTreatmentName,
  setTimeIndex,
  updateWorkerData,
}

Map<BookingErrorCodes, int> bookingCodeToInt = {
  BookingErrorCodes.copyFromObject: 7000,
  BookingErrorCodes.setDate: 7001,
  BookingErrorCodes.setWorkerPhone: 7002,
  BookingErrorCodes.setTreatmentName: 7003,
  BookingErrorCodes.setTimeIndex: 7004,
  BookingErrorCodes.updateWorkerData: 7005,
};
