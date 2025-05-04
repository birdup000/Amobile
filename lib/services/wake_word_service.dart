import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class WakeWordService {
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
    // Initialize method channel listener
    _wakeWordChannel.setMethodCallHandler(_handleMethodCall);
    
    // Load saved wake word on initialization
    loadSavedWakeWord();
  }
  
  String _currentWakeWord = _defaultWakeWord;
  String get currentWakeWord => _currentWakeWord;
  
  // AI service for processing voice commands
  final AIService _aiService = AIService();
  
  Future<void> loadSavedWakeWord() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWord = prefs.getString(_wakeWordKey);
    if (savedWord != null && savedWord.isNotEmpty) {
      _currentWakeWord = savedWord;
    }
  }
  
  Future<void> updateWakeWord(String newWakeWord) async {
    if (newWakeWord.isEmpty) return;
    
    // Validate wake word (simple validation)
    if (newWakeWord.length < 2) {
      throw Exception('Wake word must be at least 2 characters long');
    }
    
    // Update the wake word on all platforms
    _currentWakeWord = newWakeWord;
    
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wakeWordKey, newWakeWord);
    
    // Update native code wake word settings
    try {
      await _androidChannel.invokeMethod('updateWakeWord', newWakeWord);
    } catch (e) {
      print('Failed to update Android wake word: $e');
    }
    
    try {
      await _iosChannel.invokeMethod('updateWakeWord', {'wakeWord': newWakeWord});
    } catch (e) {
      print('Failed to update iOS wake word: $e');
    }
  }
  
  // Handle incoming method calls from platform channels
  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'processVoiceCommand') {
      final Map<dynamic, dynamic> args = call.arguments;
      final String transcription = args['transcription'] as String;
      
      // Process the command with AGiXT
      await processVoiceCommand(transcription);
    }
  }
  
  // Process a voice command by sending it to AGiXT
  Future<void> processVoiceCommand(String command) async {
    if (command.isEmpty) return;
    
    try {
      // Send the command to AGiXT for processing
      await _aiService.sendChatMessage(command);
    } catch (e) {
      print('Error processing voice command: $e');
    }
  }
}