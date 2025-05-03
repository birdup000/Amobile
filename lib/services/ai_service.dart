// Service for handling AI communications with AGiXT API
import 'dart:async';
import 'package:agixt/models/agixt/auth/chat.dart';
import 'package:agixt/services/bluetooth_manager.dart';
import 'package:agixt/services/whisper.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService singleton = AIService._internal();
  final BluetoothManager _bluetoothManager = BluetoothManager.singleton;
  final WhisperService _whisperService = WhisperService();
  
  bool _isProcessing = false;
  Timer? _micTimer;
  
  factory AIService() {
    return singleton;
  }
  
  AIService._internal();
  
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
      
      // Get transcription from Whisper service
      final transcription = await _whisperService.getTranscription();
      
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
      
      // Get response from AGiXT API
      final response = await ChatService.sendMessage(message);
      
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