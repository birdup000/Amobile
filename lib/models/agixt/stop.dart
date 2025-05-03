import 'package:agixt/models/agixt/agixt_dashboard.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'stop.g.dart';

@HiveType(typeId: 1)
class AGiXTStopItem {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime time;
  @HiveField(2)
  late String uuid;

  AGiXTStopItem({
    required this.title,
    required this.time,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4();
  }

  AGiXTItem toAGiXTItem() {
    return AGiXTItem(
      title: title,
      hour: time.toLocal().hour,
      minute: time.toLocal().minute,
    );
  }
}
