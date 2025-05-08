import 'package:flutter/material.dart';

/// A simple event bus to allow communication between screens
class AppEvents {
  static final List<VoidCallback> _listeners = [];
  static Map<String, dynamic>? _lastEventData;

  /// Add a listener that will be called when data changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners that data has changed
  static void notifyDataChanged() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  /// Fire a data changed event with optional data payload
  static void fireDataChanged({Map<String, dynamic>? data}) {
    _lastEventData = data;
    notifyDataChanged();
  }
  
  /// Get the data from the last event that was fired
  static Map<String, dynamic>? getLastEventData() {
    return _lastEventData;
  }
}