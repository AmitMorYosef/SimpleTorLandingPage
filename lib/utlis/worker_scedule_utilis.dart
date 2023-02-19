import 'package:simple_tor_web/utlis/times_utlis.dart';

import '../app_const/application_general.dart';
import '../app_statics.dart/worker_data.dart';
import '../models/booking_model.dart';
import '../models/treatment_model.dart';

bool isOptionalTimeForTreatment(
  DateTime timeToOrder,
  List<DateTime> defaultWork,
  List<DateTime> defaultVacations,
  List<DateTime> defaultBreaks,
  List<DateTime> defaultTakenHoures,
  List<DateTime> defaultForbbidenTimes,
) {
  /* get time DateTime(hh:mm) return true is one of the treatments
    can be set in this time */
  // all day free
  if (WorkerData.worker.closeScheduleOnHolidays &&
      isHoliday(WorkerData.worker, WorkerData.focusedDay)) {
    logger.d("Holiday is free day for this worker -> don't generate times");
    //return hours;
    return false;
  }
  DateTime bookingTimeToCheck = getValidDataTimeToCheck(timeToOrder);
  for (String treatmentName in WorkerData.worker.treatments.keys) {
    Treatment treatment = WorkerData.worker.treatments[treatmentName]!;
    Booking booking =
        getFakeBookingToCheck(treatmentName, treatment, WorkerData.focusedDay);
    if (isOptionalTimeForBooking(WorkerData.worker, booking, bookingTimeToCheck,
        defaultWork: defaultWork,
        defaultVacations: defaultVacations,
        defaultBreaks: defaultBreaks,
        defaultTakenHoures: defaultTakenHoures,
        defaultForbbidenTimes: defaultForbbidenTimes)) {
      return true;
    }
  }
  return false;
}
