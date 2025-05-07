import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CookieManager {
  static const String _agixtConversationKey = 'agixt_conversation_id';
  static const String _agixtAgentKey = 'agixt_agent_cookie';
  
  // Singleton instance
  static final CookieManager _instance = CookieManager._internal();
  
  factory CookieManager() {
    return _instance;
  }
  
  CookieManager._internal();
  
  // Save the conversation ID extracted from URL
  Future<void> saveAgixtConversationId(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_agixtConversationKey, conversationId);
      debugPrint('Saved agixt conversation ID: $conversationId');
    } catch (e) {
      debugPrint('Error saving agixt conversation ID: $e');
    }
  }
  
  // Retrieve the conversation ID
  Future<String?> getAgixtConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_agixtConversationKey);
    } catch (e) {
      debugPrint('Error getting agixt conversation ID: $e');
      return null;
    }
  }
  
  // Clear the conversation ID
  Future<void> clearAgixtConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_agixtConversationKey);
      debugPrint('Cleared agixt conversation ID');
    } catch (e) {
      debugPrint('Error clearing agixt conversation ID: $e');
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