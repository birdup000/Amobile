import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CookieManager {
  static const String _agixtConversationKey = 'agixt_conversation_cookie';
  static const String _agixtAgentKey = 'agixt_agent_cookie';
  
  // Singleton instance
  static final CookieManager _instance = CookieManager._internal();
  
  factory CookieManager() {
    return _instance;
  }
  
  CookieManager._internal();
  
  // Save the agixt-conversation cookie
  Future<void> saveAgixtConversationCookie(String cookieValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_agixtConversationKey, cookieValue);
      debugPrint('Saved agixt-conversation cookie: $cookieValue');
    } catch (e) {
      debugPrint('Error saving agixt-conversation cookie: $e');
    }
  }
  
  // Retrieve the agixt-conversation cookie
  Future<String?> getAgixtConversationCookie() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_agixtConversationKey);
    } catch (e) {
      debugPrint('Error getting agixt-conversation cookie: $e');
      return null;
    }
  }
  
  // Clear the agixt-conversation cookie
  Future<void> clearAgixtConversationCookie() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_agixtConversationKey);
      debugPrint('Cleared agixt-conversation cookie');
    } catch (e) {
      debugPrint('Error clearing agixt-conversation cookie: $e');
    }
  }
  
  // Save the agixt-agent cookie
  Future<void> saveAgixtAgentCookie(String cookieValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_agixtAgentKey, cookieValue);
      debugPrint('Saved agixt-agent cookie: $cookieValue');
    } catch (e) {
      debugPrint('Error saving agixt-agent cookie: $e');
    }
  }
  
  // Retrieve the agixt-agent cookie
  Future<String?> getAgixtAgentCookie() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_agixtAgentKey);
    } catch (e) {
      debugPrint('Error getting agixt-agent cookie: $e');
      return null;
    }
  }
}