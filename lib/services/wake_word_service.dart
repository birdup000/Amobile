import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class WakeWordService {
  final _logTag = '[WakeWordService]'; // Added for logging
  static const String _wakeWordKey = 'agixt_wake_word';
  static const String _defaultWakeWord = 'agent';
  
  // Method channels to communicate with native code
  static const MethodChannel _androidChannel = MethodChannel('dev.agixt.agixt/wake_word_settings');
  static const MethodChannel _iosChannel = MethodChannel('dev.agixt.agixt/ios_wake_word');
  static const MethodChannel _wakeWordChannel = MethodChannel('dev.agixt.agixt/wake_word');
  
  // Singleton instance
  static final WakeWordService _instance = WakeWordService._internal();
  factory WakeWordService() => _instance;
  WakeWordService._internal() {
    debugPrint('$_logTag Internal constructor called.'); // Added log
    // Initialize method channel listener
    _wakeWordChannel.setMethodCallHandler(_handleMethodCall);
    debugPrint('$_logTag Method call handler set for _wakeWordChannel.'); // Added log

    // Load saved wake word on initialization
    loadSavedWakeWord();
  }
  
  String _currentWakeWord = _defaultWakeWord;
  String get currentWakeWord => _currentWakeWord;
  
  // AI service for processing voice commands
  final AIService _aiService = AIService();
  
  Future<void> loadSavedWakeWord() async {
    debugPrint('$_logTag Loading saved wake word...'); // Added log
    final prefs = await SharedPreferences.getInstance();
    final savedWord = prefs.getString(_wakeWordKey);
    if (savedWord != null && savedWord.isNotEmpty) {
      _currentWakeWord = savedWord;
      debugPrint('$_logTag Loaded wake word: $_currentWakeWord'); // Added log
    } else {
      debugPrint('$_logTag No saved wake word found, using default: $_currentWakeWord'); // Added log
    }
  }
  
  Future<void> updateWakeWord(String newWakeWord) async {
    debugPrint('$_logTag Attempting to update wake word to: $newWakeWord'); // Added log
    if (newWakeWord.isEmpty) {
       debugPrint('$_logTag Update cancelled: New wake word is empty.'); // Added log
       return;
    }

    // Validate wake word (simple validation)
    if (newWakeWord.length < 2) {
      debugPrint('$_logTag Update failed: Wake word too short.'); // Added log
      throw Exception('Wake word must be at least 2 characters long');
    }

    // Update the wake word on all platforms
    _currentWakeWord = newWakeWord;
    debugPrint('$_logTag Internal wake word updated to: $_currentWakeWord'); // Added log

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wakeWordKey, newWakeWord);
    debugPrint('$_logTag Wake word saved to preferences.'); // Added log

    // Update native code wake word settings
    try {
      debugPrint('$_logTag Invoking Android updateWakeWord...'); // Added log
      await _androidChannel.invokeMethod('updateWakeWord', newWakeWord);
      debugPrint('$_logTag Android updateWakeWord invoked successfully.'); // Added log
    } catch (e) {
      debugPrint('$_logTag Failed to update Android wake word: $e'); // Modified log
    }

    try {
      debugPrint('$_logTag Invoking iOS updateWakeWord...'); // Added log
      await _iosChannel.invokeMethod('updateWakeWord', {'wakeWord': newWakeWord});
      debugPrint('$_logTag iOS updateWakeWord invoked successfully.'); // Added log
    } catch (e) {
      debugPrint('$_logTag Failed to update iOS wake word: $e'); // Modified log
    }
  }
  
  // Handle incoming method calls from platform channels
  Future<void> _handleMethodCall(MethodCall call) async {
    debugPrint('$_logTag Received method call: ${call.method}'); // Added log
    if (call.method == 'processVoiceCommand') {
      debugPrint('$_logTag Handling processVoiceCommand call...'); // Added log
      final Map<dynamic, dynamic>? args = call.arguments as Map?; // Safe cast
      final String? transcription = args?['transcription'] as String?; // Safe access

      if (transcription != null && transcription.isNotEmpty) {
         debugPrint('$_logTag Transcription received: "$transcription"'); // Added log
         // Process the command with AGiXT
         await processVoiceCommand(transcription);
      } else {
         debugPrint('$_logTag Received processVoiceCommand call with null or empty transcription.'); // Added log
      }
    } else {
       debugPrint('$_logTag Received unhandled method call: ${call.method}'); // Added log
    }
  }
  
  // Process a voice command by sending it to AGiXT
  Future<void> processVoiceCommand(String command) async {
    debugPrint('$_logTag Processing voice command: "$command"'); // Added log
    if (command.isEmpty) {
       debugPrint('$_logTag Command is empty, skipping processing.'); // Added log
       return;
    }

    try {
      debugPrint('$_logTag Calling AI Service processWakeWordCommand...'); // Added log
      // Send the command to AGiXT for processing using the correct method
      await _aiService.processWakeWordCommand(command);
      debugPrint('$_logTag AI Service processWakeWordCommand finished.'); // Added log
    } catch (e) {
      debugPrint('$_logTag Error processing voice command via AI Service: $e'); // Modified log
    }
  }
}