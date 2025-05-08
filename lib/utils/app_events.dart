import 'package:flutter/material.dart';

/// A simple event bus to allow communication between screens
class AppEvents {
  static final List<VoidCallback> _listeners = [];

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
}