import 'package:agixt/models/g1/time_weather.dart'; // Added import for enums
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

  // Weather Provider State
  static const platform = MethodChannel('dev.agixt.agixt/weather');
  List<Map<String, String>> _weatherProviders = [];
  String? _selectedWeatherProviderPackageName;
  bool _isLoadingProviders = true;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchWeatherProviders(); // Fetch providers on init
  }

  // Load settings from UiPerfs
  void _loadSettings() {
    setState(() {
      _is24HourFormat = UiPerfs.singleton.timeFormat == TimeFormat.TWENTY_FOUR_HOUR; // Corrected enum value
      _isCelsius = UiPerfs.singleton.temperatureUnit == TemperatureUnit.CELSIUS;
      _selectedWeatherProviderPackageName = UiPerfs.singleton.weatherProviderPackageName;
      // Ensure the loaded package name is valid among fetched providers
      if (_weatherProviders.isNotEmpty && !_weatherProviders.any((p) => p['packageName'] == _selectedWeatherProviderPackageName)) {
        _selectedWeatherProviderPackageName = null; // Reset if saved provider not found
      }
    });
  }

  // Fetch compatible weather providers from native side
  Future<void> _fetchWeatherProviders() async {
    setState(() {
      _isLoadingProviders = true;
      _fetchError = null;
    });
    try {
      final List<dynamic>? providers = await platform.invokeMethod('getWeatherProviders');
      if (providers != null) {
        setState(() {
          // Cast the dynamic list to the expected type
          _weatherProviders = List<Map<String, String>>.from(
            providers.map((item) => Map<String, String>.from(item as Map))
          );
          // Reload settings to potentially update selected provider based on fetched list
          _loadSettings();
        });
      }
    } on PlatformException catch (e) {
       setState(() {
         _fetchError = "Failed to get weather providers: ${e.message}";
       });
       print("Failed to get weather providers: '${e.message}'.");
    } finally {
      setState(() {
        _isLoadingProviders = false;
      });
    }
  }

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
            SizedBox(height: 20),
            Text(
              'Weather data is provided by your favorite weather app on Android using the Gadgetbridge protocol.',
              style: TextStyle(fontSize: 16),
            ),
            GestureDetector(
              onTap: () => _launchURL(
                  'https://gadgetbridge.org/internals/development/weather-support'),
              child: Text(
                'Learn more about Gadgetbridge weather support',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Looking for a weather app?", style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () =>
                  _launchURL('https://f-droid.org/packages/org.breezyweather'),
              child: Text(
                'Try Breezy Weather!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Weather Provider App', style: Theme.of(context).textTheme.titleMedium),
            _buildWeatherProviderSelector(), // Add the selector widget
          ],
        ),
      ),
    );
  }

  // Widget to build the weather provider dropdown or status messages
  Widget _buildWeatherProviderSelector() {
    if (_isLoadingProviders) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 10),
            Text('Discovering weather apps...'),
          ],
        ),
      );
    }

    if (_fetchError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Error: $_fetchError', style: TextStyle(color: Colors.red)),
      );
    }

    if (_weatherProviders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No compatible weather provider apps found.'),
      );
    }

    // Ensure the selected value exists in the items, default if not
    String? currentSelection = _selectedWeatherProviderPackageName;
    if (currentSelection != null && !_weatherProviders.any((p) => p['packageName'] == currentSelection)) {
      currentSelection = null; // Reset if saved provider is no longer available
    }


    return DropdownButton<String>(
      value: currentSelection,
      hint: Text('Select Weather App'),
      isExpanded: true,
      items: _weatherProviders.map<DropdownMenuItem<String>>((provider) {
        return DropdownMenuItem<String>(
          value: provider['packageName'],
          child: Text(provider['name'] ?? 'Unknown App'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedWeatherProviderPackageName = newValue;
          });
          // Save the selected package name
          UiPerfs.singleton.weatherProviderPackageName = newValue;
          // Optional: Trigger sync if needed, though weather display is separate
          // _bluetoothManager.sync();
        }
      },
    );
  }
}
