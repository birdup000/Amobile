import 'package:device_calendar/device_calendar.dart';
import 'package:agixt/models/agixt/agixt_dashboard.dart';
import 'package:hive/hive.dart';

part 'calendar.g.dart';

@HiveType(typeId: 2)
class AGiXTCalendar {
  @HiveField(0)
  String id;
  @HiveField(1)
  bool enabled;

  AGiXTCalendar({
    required this.id,
    required this.enabled,
  });
}

class AGiXTCalendarComposer {
  final calendarBox = Hive.box<AGiXTCalendar>('agixtCalendarBox');

  Future<List<AGiXTItem>> toAGiXTItems() async {
    final deviceCal = DeviceCalendarPlugin();
    final fpCals = calendarBox.values.toList();

    final items = <AGiXTItem>[];

    for (var cal in fpCals) {
      if (!cal.enabled) {
        continue;
      }

      final events = await deviceCal.retrieveEvents(
          cal.id,
          RetrieveEventsParams(
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
          ));

      for (var event in events.data ?? []) {
        if (event.start == null) {
          continue;
        }
        if (!_isToday(event.start!)) {
          continue;
        }

        final start = event.start!;
        items.add(AGiXTItem(
          title: event.title,
          hour: start.toLocal().hour,
          minute: start.toLocal().minute,
        ));
      }
    }

    return items;
  }

  bool _isToday(DateTime time) {
    time = time.toLocal();
    final now = DateTime.now().toLocal();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }
}
