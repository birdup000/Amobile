// Removed import for time_weather.dart
import 'package:agixt/services/bluetooth_manager.dart';
import 'package:agixt/utils/ui_perfs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for MethodChannel
// import 'package:shared_preferences/shared_preferences.dart'; // Removed import
import 'package:url_launcher/url_launcher.dart';

class DashboardSettingsPage extends StatefulWidget {
  const DashboardSettingsPage({super.key});

  @override
  DashboardSettingsPageState createState() => DashboardSettingsPageState();
}

class DashboardSettingsPageState extends State<DashboardSettingsPage> {
  bool _is24HourFormat = UiPerfs.singleton.timeFormat == TimeFormat.TWENTY_FOUR_HOUR; // Corrected enum value
  bool _isCelsius = UiPerfs.singleton.temperatureUnit == TemperatureUnit.CELSIUS; // Use UiPerfs
  final BluetoothManager _bluetoothManager = BluetoothManager(); // Added BluetoothManager instance

  // Removed Weather Provider State variables

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from UiPerfs
  void _loadSettings() {
    setState(() {
      _is24HourFormat = UiPerfs.singleton.timeFormat == TimeFormat.TWENTY_FOUR_HOUR; // Corrected enum value
      _isCelsius = UiPerfs.singleton.temperatureUnit == TemperatureUnit.CELSIUS;
      // Removed weather provider package name loading and validation
    });
  }

  // Removed _fetchWeatherProviders method

  // Save settings to UiPerfs and trigger update
  Future<void> _saveSettingsAndTriggerUpdate() async {
    UiPerfs.singleton.timeFormat = _is24HourFormat
        ? TimeFormat.TWENTY_FOUR_HOUR // Corrected enum value
        : TimeFormat.TWELVE_HOUR; // Corrected enum value
    UiPerfs.singleton.temperatureUnit =
        _isCelsius ? TemperatureUnit.CELSIUS : TemperatureUnit.FAHRENHEIT;
    // await UiPerfs.singleton.save(); // Removed explicit save call (assuming setters handle it)
    // Trigger dashboard update via Bluetooth
    _bluetoothManager.sync(); // Correct method is sync()
  }

  void _launchURL(String to) async {
    final url = Uri.parse(to);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: _is24HourFormat
                  ? Text('24-hour time format')
                  : Text('12-hour time format'),
              value: _is24HourFormat,
              onChanged: (bool value) {
                setState(() {
                  _is24HourFormat = value;
                });
                _saveSettingsAndTriggerUpdate(); // Call updated save function
              },
            ),
            SwitchListTile(
              title: _isCelsius
                  ? Text('Weather in Celsius')
                  : Text('Weather in Fahrenheit'),
              value: _isCelsius,
              onChanged: (bool value) {
                setState(() {
                  _isCelsius = value;
                });
                _saveSettingsAndTriggerUpdate(); // Call updated save function
              },
            ),
            // Removed Weather Provider section and selector UI
          ],
        ),
      ),
    );
  }

  // Removed _buildWeatherProviderSelector method
}
