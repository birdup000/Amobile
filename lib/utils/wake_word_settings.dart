import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WakeWordSettings manages the user's custom wake word preferences
class WakeWordSettings {
  static final WakeWordSettings singleton = WakeWordSettings._internal();
  static const String _wakeWordKey = 'wake_word';
  static const String _defaultWakeWord = 'agent';
  
  final MethodChannel _androidSettingsChannel = const MethodChannel('dev.agixt.agixt/wake_word_settings');
  String _currentWakeWord = _defaultWakeWord;
  
  factory WakeWordSettings() {
    return singleton;
  }
  
  WakeWordSettings._internal();
  
  /// Initialize the wake word settings by loading from shared preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentWakeWord = prefs.getString(_wakeWordKey) ?? _defaultWakeWord;
      debugPrint('Loaded wake word: $_currentWakeWord');
      
      // Synchronize with platform-specific implementations
      await _updatePlatformWakeWord(_currentWakeWord);
    } catch (e) {
      debugPrint('Error initializing wake word settings: $e');
    }
  }
  
  /// Get the current wake word
  String get wakeWord => _currentWakeWord;
  
  /// Get the default wake word
  String get defaultWakeWord => _defaultWakeWord;
  
  /// Update the wake word
  Future<bool> updateWakeWord(String newWakeWord) async {
    if (newWakeWord.isEmpty) {
      return false;
    }
    
    try {
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wakeWordKey, newWakeWord);
      
      // Update internal state
      _currentWakeWord = newWakeWord;
      
      // Synchronize with platform-specific implementations
      await _updatePlatformWakeWord(newWakeWord);
      
      debugPrint('Updated wake word to: $newWakeWord');
      return true;
    } catch (e) {
      debugPrint('Error updating wake word: $e');
      return false;
    }
  }
  
  /// Reset to default wake word
  Future<bool> resetToDefault() async {
    return await updateWakeWord(_defaultWakeWord);
  }
  
  /// Updates the wake word in platform-specific code
  Future<void> _updatePlatformWakeWord(String wakeWord) async {
    try {
      // Update Android native wake word
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _androidSettingsChannel.invokeMethod('updateWakeWord', wakeWord);
      }
      
      // Update iOS native wake word
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await const MethodChannel('dev.agixt.agixt/ios_wake_word')
            .invokeMethod('updateWakeWord', {'wakeWord': wakeWord});
      }
    } catch (e) {
      debugPrint('Error updating platform wake word: $e');
    }
  }
}