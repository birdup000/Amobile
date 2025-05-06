// Service for handling AI communications with AGiXT API
import 'dart:async';
import 'package:agixt/models/agixt/widgets/agixt_chat.dart';
import 'package:agixt/services/bluetooth_manager.dart';
import 'package:agixt/services/whisper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Import Services

class AIService {
  // MethodChannel for button events from native code
  static const MethodChannel _buttonEventsChannel = MethodChannel('dev.agixt.agixt/button_events');
  
  static final AIService singleton = AIService._internal();
  final BluetoothManager _bluetoothManager = BluetoothManager.singleton;
  WhisperService? _whisperService;
  final AGiXTChatWidget _chatWidget = AGiXTChatWidget();
  
  bool _isProcessing = false;
  Timer? _micTimer;
  
  factory AIService() {
    return singleton;
  }
  
  AIService._internal() {
    _initWhisperService();
    // Set up the method call handler for button events
    _buttonEventsChannel.setMethodCallHandler(_handleButtonEvents);
  }
  
  // Handle method calls from the button events channel
  Future<void> _handleButtonEvents(MethodCall call) async {
    switch (call.method) {
      case 'sideButtonPressed':
        debugPrint('Side button press event received from native code.');
        await handleSideButtonPress();
        break;
      default:
        debugPrint('Unknown method call from button events channel: ${call.method}');
    }
  }
  
  // Initialize the WhisperService using the factory method
  Future<void> _initWhisperService() async {
    _whisperService = await WhisperService.service();
  }
  
  // Handle side button press to activate voice input and AI response
  Future<void> handleSideButtonPress() async {
    if (_isProcessing) {
      debugPrint('Already processing a request');
      return;
    }
    
    _isProcessing = true;
    try {
      await _showListeningIndicator();
      
      // Open microphone
      await _bluetoothManager.setMicrophone(true);
      
      // Set a timeout for voice recording (5 seconds)
      _micTimer = Timer(const Duration(seconds: 5), () async {
        await _processSpeechToText();
      });
      
    } catch (e) {
      debugPrint('Error handling side button press: $e');
      _isProcessing = false;
      await _showErrorMessage('Failed to process voice input');
    }
  }
  
  // Process recorded speech using Whisper service
  Future<void> _processSpeechToText() async {
    _micTimer?.cancel();
    
    try {
      // Close microphone
      await _bluetoothManager.setMicrophone(false);
      
      // Show processing message
      await _showProcessingMessage();
      
      // Initialize WhisperService if not already initialized
      if (_whisperService == null) {
        await _initWhisperService();
      }
      
      // Get transcription from Whisper service
      final transcription = await _whisperService?.getTranscription();
      
      if (transcription != null && transcription.isNotEmpty) {
        // Send message to AGiXT API
        await _sendMessageToAGiXT(transcription);
      } else {
        await _showErrorMessage('No speech detected');
      }
    } catch (e) {
      debugPrint('Error processing speech to text: $e');
      await _showErrorMessage('Error processing voice input');
    } finally {
      _isProcessing = false;
    }
  }
  
  // Send message to AGiXT API and display response
  Future<void> _sendMessageToAGiXT(String message) async {
    try {
      // Show sending message
      await _bluetoothManager.sendText('Sending to AGiXT: "$message"');
      
      // Get response using the AGiXTChatWidget
      final response = await _chatWidget.sendChatMessage(message);
      
      if (response != null && response.isNotEmpty) {
        // Display response on glasses
        await _bluetoothManager.sendText(response);
      } else {
        await _showErrorMessage('No response from AGiXT');
      }
    } catch (e) {
      debugPrint('Error sending message to AGiXT: $e');
      await _showErrorMessage('Failed to get response from AGiXT');
    }
  }
  
  // Process wake word command received from native code
  Future<void> processWakeWordCommand(String commandText) async {
    if (_isProcessing) {
      debugPrint('Already processing a request');
      return;
    }
    
    _isProcessing = true;
    try {
      // Show that we're processing a wake word command
      await _bluetoothManager.sendText('Processing wake word command...');
      
      // Send the command to AGiXT without requiring button press
      await _sendMessageToAGiXT(commandText);
    } catch (e) {
      debugPrint('Error processing wake word command: $e');
      await _showErrorMessage('Error processing wake word command');
    } finally {
      _isProcessing = false;
    }
  }
  
  // Helper methods for displaying status messages
  Future<void> _showListeningIndicator() async {
    await _bluetoothManager.sendText('Listening...');
  }
  
  Future<void> _showProcessingMessage() async {
    await _bluetoothManager.sendText('Processing...');
  }
  
  Future<void> _showErrorMessage(String message) async {
    await _bluetoothManager.sendText('Error: $message');
  }
}