import 'dart:typed_data';

import 'package:agixt/models/g1/dashboard.dart';
import 'package:agixt/utils/ui_perfs.dart'; // Import UiPerfs

class DashboardController {
  static final DashboardController _singleton = DashboardController._internal();

  List<int> dashboardLayout = DashboardLayout.DASHBOARD_DUAL;

  factory DashboardController() {
    return _singleton;
  }

  DashboardController._internal();

  int _seqId = 0;

  // Removed _getTimeFormatFromPreferences
  // Removed _getTemperatureUnitFromPreferences

  Future<List<Uint8List>> updateDashboardCommand() async {
    final UiPerfs uiPerfs = UiPerfs.singleton; // Get UiPerfs instance
    List<Uint8List> commands = [];
    // Removed weather fetching and TimeAndWeather command

    List<int> dashlayoutCommand =
        DashboardLayout.DASHBOARD_CHANGE_COMMAND.toList();
    dashlayoutCommand.addAll(dashboardLayout);

    commands.add(Uint8List.fromList(dashlayoutCommand));

    return commands;
  }
}
