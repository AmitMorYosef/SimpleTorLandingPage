import 'dart:collection';
import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/app_const/platform.dart';
import 'package:management_system_app/services/clients/secured_storage_client.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DeviceCalendar {
  static final DeviceCalendarPlugin _myPlugin = DeviceCalendarPlugin();
  static String cachedCalendarId = '';

  static Future<bool> hasPermission() async {
    return (await _myPlugin.hasPermissions()).isSuccess;
  }

  static Future<void> addEvent(
      {String? title,
      Duration? notifyBeforDuration,
      String? instagram,
      required String key,
      required String decription,
      required String location,
      required DateTime startDate,
      required DateTime endDate}) async {
    if (isWeb) return;
    tz.initializeTimeZones();
    await getCalendarId();
    if (cachedCalendarId == "") return;
    try {
      String? eventId = await getEventId(key);
      if (Platform.isAndroid && eventId != null) {
        // updating android
        await removeEvent(key: key);
        eventId = null;
      }
      Event calendarEvent = Event(cachedCalendarId,
          eventId: eventId,
          title: title ?? translate('booking') + " - Simple tor",
          description: decription,
          location: location,
          end: tz.TZDateTime.from(endDate, tz.local),
          start: tz.TZDateTime.from(startDate, tz.local));
      Result result = (await _myPlugin.createOrUpdateEvent(calendarEvent))!;
      if (result.data != eventId)
        await SecuredStorageClient().updateKeyInDeviceStorage(
            key: key, value: "${result.data}&&${cachedCalendarId}");
      logger.d("Event success -->  ${result.isSuccess}");
    } catch (e) {
      logger.e("Error while adding event  --> $e");
    }
  }

  static Future<String?> getEventId(String id) async {
    try {
      final eventData =
          await SecuredStorageClient().readKeyInDeviceStorage(key: id);
      return eventData == '' ? null : eventData.split("&&")[0];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getEventCalendarId(String id) async {
    try {
      final eventData =
          await SecuredStorageClient().readKeyInDeviceStorage(key: id);
      return eventData == '' ? null : eventData.split("&&")[1];
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeEvent({
    required String key,
  }) async {
    if (isWeb) return;
    if (!await hasPermission()) return;
    try {
      await _myPlugin.deleteEvent(
          await getEventCalendarId(key), await getEventId(key));
      await SecuredStorageClient().deleteKeyInDeviceStorage(key: key);
    } catch (e) {
      logger.e("Error while removing event  --> $e");
    }
  }

  static Future<String> getCalendarId() async {
    try {
      if (cachedCalendarId != '') return cachedCalendarId;
      UnmodifiableListView<Calendar> calendars =
          (await _myPlugin.retrieveCalendars()).data!;
      Calendar calendar = Calendar(id: "");
      for (Calendar temp in calendars) {
        if (temp.isReadOnly != null && !temp.isReadOnly!) {
          calendar = temp;
          break;
        }
      }
      cachedCalendarId = calendar.id!;
    } catch (e) {
      cachedCalendarId = "";
    }
    return cachedCalendarId;
  }
}
