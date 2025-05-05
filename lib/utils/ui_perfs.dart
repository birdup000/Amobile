import 'package:shared_preferences/shared_preferences.dart';
import 'package:agixt/models/g1/time_weather.dart';

class UiPerfs {
  static final UiPerfs singleton = UiPerfs._internal();

  factory UiPerfs() {
    return singleton;
  }

  UiPerfs._internal();

  bool _trainNerdMode = false;
  bool get trainNerdMode => _trainNerdMode;
  set trainNerdMode(bool value) => _setTrainNerdMode(value);

  // Default to Fahrenheit
  TemperatureUnit _temperatureUnit = TemperatureUnit.FAHRENHEIT;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  set temperatureUnit(TemperatureUnit value) => _setTemperatureUnit(value);

  // Default to 12-hour format
  TimeFormat _timeFormat = TimeFormat.TWELVE_HOUR;
  TimeFormat get timeFormat => _timeFormat;
  set timeFormat(TimeFormat value) => _setTimeFormat(value);

  // Weather Provider Preference
  static const String _weatherProviderPackageNameKey = 'weatherProviderPackageName';
  String _weatherProviderPackageName = '';
  String get weatherProviderPackageName => _weatherProviderPackageName;
  set weatherProviderPackageName(String value) => _setWeatherProviderPackageName(value);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _trainNerdMode = prefs.getBool('trainNerdMode') ?? false;
    
    // Load temperature unit preference (0 for Celsius, 1 for Fahrenheit)
    final tempUnitIdx = prefs.getInt('temperatureUnit') ?? 1;
    _temperatureUnit = TemperatureUnit.values[tempUnitIdx];
    
    // Load time format preference (0 for 12-hour, 1 for 24-hour)
    final timeFormatIdx = prefs.getInt('timeFormat') ?? 0;
    _timeFormat = TimeFormat.values[timeFormatIdx];

    // Load weather provider preference
    _weatherProviderPackageName = prefs.getString(_weatherProviderPackageNameKey) ?? '';
  }

  void _setTrainNerdMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _trainNerdMode = value;
    prefs.setBool('trainNerdMode', value);
  }

  void _setTemperatureUnit(TemperatureUnit value) async {
    final prefs = await SharedPreferences.getInstance();
    _temperatureUnit = value;
    prefs.setInt('temperatureUnit', value.index);
  }

  void _setTimeFormat(TimeFormat value) async {
    final prefs = await SharedPreferences.getInstance();
    _timeFormat = value;
    prefs.setInt('timeFormat', value.index);
  }

  void _setWeatherProviderPackageName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    _weatherProviderPackageName = value;
    prefs.setString(_weatherProviderPackageNameKey, value);
  }
}
