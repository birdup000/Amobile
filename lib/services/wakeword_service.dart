import 'package:flutter/services.dart';
import 'package:agixt/services/ai_service.dart'; // Assuming AIService is in this path
import 'package:flutter/foundation.dart'; // For debugPrint

class WakewordService {
  static const MethodChannel _channel = MethodChannel('dev.agixt.agixt/wakeword');

  // Private constructor for singleton pattern or to prevent direct instantiation
  WakewordService._privateConstructor();
  static final WakewordService singleton = WakewordService._privateConstructor();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint("WakewordService already initialized.");
      return;
    }
    _channel.setMethodCallHandler(_handleMethodCall);
    debugPrint("WakewordService initialized and method call handler set.");
    _isInitialized = true;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onWakewordDetected':
        _handleWakewordDetected();
        break;
      default:
        debugPrint('Unknown method call received: ${call.method}');
    }
  }

  void _handleWakewordDetected() {
    debugPrint("Wakeword detected! Triggering AI Service voice input (simulating side button press).");
    // Ensure AIService.singleton is not null and its methods can be called.
    // This might require ensuring AIService is initialized before this point,
    // or adding null checks and error handling here.
    if (AIService.singleton != null) {
      AIService.singleton.handleSideButtonPress();
    } else {
      debugPrint("AIService.singleton is null. Cannot handle wakeword detection.");
      // Potentially queue this action or notify the user/system.
    }
  }

  Future<void> startWakewordDetection() async {
    if (!_isInitialized) {
      debugPrint("WakewordService not initialized. Call initialize() first.");
      // Optionally, initialize automatically: await initialize();
      // However, explicit initialization is often preferred.
      return;
    }
    try {
      await _channel.invokeMethod('startWakewordDetection');
      debugPrint("Requested to start wakeword detection on native side.");
    } on PlatformException catch (e) {
      debugPrint("Failed to start wakeword detection: '${e.message}'.");
    }
  }

  Future<void> stopWakewordDetection() async {
    if (!_isInitialized) {
      debugPrint("WakewordService not initialized.");
      return;
    }
    try {
      await _channel.invokeMethod('stopWakewordDetection');
      debugPrint("Requested to stop wakeword detection on native side.");
    } on PlatformException catch (e) {
      debugPrint("Failed to stop wakeword detection: '${e.message}'.");
    }
  }
}
