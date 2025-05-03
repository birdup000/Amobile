import 'package:agixt/models/agixt/agixt_dashboard.dart';
import 'package:hive/hive.dart';

part 'daily.g.dart';

@HiveType(typeId: 0)
class AGiXTDailyItem {
  @HiveField(0)
  String title;
  @HiveField(1)
  int? hour;
  @HiveField(2)
  int? minute;

  AGiXTDailyItem({
    required this.title,
    this.hour,
    this.minute,
  });

  AGiXTItem toAGiXTItem() {
    return AGiXTItem(
      title: title,
      hour: hour,
      minute: minute,
    );
  }
}
