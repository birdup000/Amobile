import 'package:agixt/models/agixt/widgets/agixt_widget.dart';
import 'package:agixt/models/g1/note.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'checklist.g.dart';

@HiveType(typeId: 3)
class AGiXTChecklist extends AGiXTWidget {
  @HiveField(0)
  late String uuid;

  @HiveField(1)
  String name;
  @HiveField(2)
  int duration;
  @HiveField(4)
  DateTime? showUntil;
  @HiveField(5)
  List<AGiXTCheckListItem> items = [];

  @override
  int getPriority() {
    return 1;
  }

  static int _getBestMatchIndex(String name) {
    final box = Hive.box<AGiXTChecklist>('agixtChecklistBox');
    final allLists = box.values.toList();
    int maxScore = 0;
    int index = -1;
    for (final list in allLists) {
      final score = ratio(name.toLowerCase(), list.name.toLowerCase());
      debugPrint('Score for $name and ${list.name}: $score');
      if (score > maxScore) {
        maxScore = score;
        index = allLists.indexOf(list);
      }
    }
    if (maxScore > 70) {
      return index;
    }
    return -1;
  }

  static AGiXTChecklist? displayChecklistFor(String name) {
    final bestMatchIndex = _getBestMatchIndex(name);
    if (bestMatchIndex == -1) {
      return null;
    }
    final box = Hive.box<AGiXTChecklist>('agixtChecklistBox');
    final bestMatch = box.getAt(bestMatchIndex);
    if (bestMatch != null) {
      bestMatch.showNow();
      box.putAt(bestMatchIndex, bestMatch);
      return bestMatch;
    }
    return null;
  }

  static AGiXTChecklist? hideChecklistFor(String name) {
    final bestMatchIndex = _getBestMatchIndex(name);
    if (bestMatchIndex == -1) {
      return null;
    }
    final box = Hive.box<AGiXTChecklist>('agixtChecklistBox');
    final bestMatch = box.getAt(bestMatchIndex);
    if (bestMatch != null) {
      bestMatch.hide();
      box.putAt(bestMatchIndex, bestMatch);
      return bestMatch;
    }
    return null;
  }

  AGiXTChecklist({
    required this.name,
    required this.duration,
    this.showUntil,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4();
  }

  Duration getDuration() {
    return Duration(minutes: duration);
  }

  void setDuration(Duration duration) {
    this.duration = duration.inMinutes;
  }

  void showNow() {
    showUntil = DateTime.now().add(getDuration());
  }

  void hide() {
    showUntil = null;
  }

  bool get isShown {
    return showUntil != null && showUntil!.isAfter(DateTime.now());
  }

  @override
  Future<List<Note>> generateDashboardItems() async {
    if (showUntil == null || showUntil!.isBefore(DateTime.now())) {
      return [];
    }
    final notes = <Note>[];

    for (int i = 0; i < items.length; i += 4) {
      List<String> lines = [];
      for (int j = 0; j < 4; j++) {
        if (i + j >= items.length) {
          break;
        }
        lines.add('${NoteSupportedIcons.CHECK} ${items[i + j].title}');
      }

      notes.add(Note(
        noteNumber: 1, // dummy
        name: '$name - ${((i / 4) + 1).ceil()}/${(items.length / 4).ceil()}',
        text: lines.join('\n'),
      ));
    }

    return notes;
  }
}

@HiveType(typeId: 4)
class AGiXTCheckListItem {
  @HiveField(0)
  String title;

  AGiXTCheckListItem({
    required this.title,
  });
}
