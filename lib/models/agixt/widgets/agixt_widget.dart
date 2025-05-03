import 'package:agixt/models/g1/note.dart';

abstract class AGiXTWidget {
  int getPriority();
  Future<List<Note>> generateDashboardItems() {
    throw UnimplementedError();
  }
}
