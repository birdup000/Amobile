import 'dart:convert';
import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:agixt/models/agixt/widgets/agixt_widget.dart';
import 'package:agixt/models/g1/note.dart';
import 'package:agixt/services/cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AGiXTChatWidget implements AGiXTWidget {
  static const String DEFAULT_MODEL = "XT";
  static const int DEFAULT_PRIORITY = 1;

  @override
  int getPriority() {
    return DEFAULT_PRIORITY;
  }

  // Get the agent name from cookie or use default
  Future<String> _getAgentName() async {
    final cookieManager = CookieManager();
    final agentName = await cookieManager.getAgixtAgentCookie();

    // Return the agent name from cookie or default to EVEN_REALITIES_GLASSES
    return agentName?.isNotEmpty == true ? agentName! : DEFAULT_MODEL;
  }

  @override
  Future<List<Note>> generateDashboardItems() async {
    // Get the user's last question and response if available
    final lastInteraction = await _getLastInteraction();
    if (lastInteraction != null) {
      final note = Note(
        noteNumber: 1,
        name: 'Recent AI Chat',
        text: 'Q: ${lastInteraction.question}\nA: ${lastInteraction.answer}',
      );
      return [note];
    }

    // If no previous interaction, return a welcome note
    return [
      Note(
        noteNumber: 1,
        name: 'AGiXT Chat',
        text: 'Press the side button to speak with AGiXT AI assistant.',
      )
    ];
  }

  // Send a message to the AGiXT chat completions API
  Future<String?> sendChatMessage(String message) async {
    try {
      final jwt = await AuthService.getJwt();
      if (jwt == null) {
        return "Please login to use AGiXT chat.";
      }

      // Get the conversation ID from URL or use "-" as default
      final cookieManager = CookieManager();
      final conversationId = await cookieManager.getAgixtConversationId() ?? "-";
      
      debugPrint('Using conversation ID: $conversationId');

      // Create chat request
      final requestBody = {
        "model": await _getAgentName(),
        "messages": [
          {"role": "user", "content": message}
        ],
        "user": conversationId // Use the conversation ID from URL for the user field
      };

      // Send request to AGiXT API
      final response = await http.post(
        Uri.parse('${AuthService.serverUrl}/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwt,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['choices'] != null && 
            jsonResponse['choices'].isNotEmpty &&
            jsonResponse['choices'][0]['message'] != null) {
          final answer = jsonResponse['choices'][0]['message']['content'];
          
          // Save this interaction for future reference
          await _saveInteraction(message, answer);
          
          return answer;
        }
      } else if (response.statusCode == 401) {
        // JWT may be expired
        await AuthService.logout();
        return "Authentication expired. Please login again.";
      }
      
      return "Sorry, I couldn't get a response at this time.";
    } catch (e) {
      debugPrint('AGiXT Chat error: $e');
      return "An error occurred while connecting to AGiXT.";
    }
  }

  // Store the last interaction
  Future<void> _saveInteraction(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agixt_last_question', question);
    await prefs.setString('agixt_last_answer', answer);
    await prefs.setString('agixt_last_timestamp',
        DateTime.now().millisecondsSinceEpoch.toString());
  }

  // Retrieve the last interaction if it exists and is not too old
  Future<ChatInteraction?> _getLastInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    final question = prefs.getString('agixt_last_question');
    final answer = prefs.getString('agixt_last_answer');
    final timestamp = prefs.getString('agixt_last_timestamp');

    if (question == null || answer == null || timestamp == null) {
      return null;
    }

    // Check if the interaction is from the last 24 hours
    final interactionTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();
    if (now.difference(interactionTime).inHours > 24) {
      return null; // Interaction is too old
    }

    return ChatInteraction(
        question: question, answer: answer, timestamp: interactionTime);
  }
}

// Simple class to store chat interactions
class ChatInteraction {
  final String question;
  final String answer;
  final DateTime timestamp;

  ChatInteraction({
    required this.question,
    required this.answer,
    required this.timestamp,
  });
}
