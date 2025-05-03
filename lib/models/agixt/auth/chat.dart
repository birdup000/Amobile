// Models for AGiXT chat completions
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../auth/auth.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }
}

class ChatCompletionRequest {
  final String model;
  final List<ChatMessage> messages;
  final String user;

  ChatCompletionRequest({
    required this.model,
    required this.messages,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((message) => message.toJson()).toList(),
        'user': user,
      };
}

class ChatCompletionChoice {
  final int index;
  final ChatMessage message;
  final String finishReason;

  ChatCompletionChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChatCompletionChoice.fromJson(Map<String, dynamic> json) {
    return ChatCompletionChoice(
      index: json['index'],
      message: ChatMessage.fromJson(json['message']),
      finishReason: json['finish_reason'],
    );
  }
}

class ChatCompletionUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatCompletionUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatCompletionUsage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionUsage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}

class ChatCompletionResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatCompletionChoice> choices;
  final ChatCompletionUsage usage;

  ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List)
          .map((choice) => ChatCompletionChoice.fromJson(choice))
          .toList(),
      usage: ChatCompletionUsage.fromJson(json['usage']),
    );
  }

  String? get responseContent {
    if (choices.isNotEmpty) {
      return choices[0].message.content;
    }
    return null;
  }
}

class ChatService {
  static const String MODEL = "EVEN_REALITIES_GLASSES";

  // Send a message to the AGiXT API
  static Future<String?> sendMessage(String message) async {
    try {
      final jwt = await AuthService.getJwt();
      if (jwt == null) {
        return null;
      }

      // Create conversation name using current date
      final today = DateTime.now();
      final conversationName = DateFormat('yyyy-MM-dd').format(today);

      // Create request
      final request = ChatCompletionRequest(
        model: MODEL,
        messages: [
          ChatMessage(role: 'user', content: message),
        ],
        user: conversationName,
      );

      // Send request to AGiXT API
      final response = await http.post(
        Uri.parse('${AuthService.serverUrl}/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwt,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final completionResponse = ChatCompletionResponse.fromJson(jsonResponse);
        return completionResponse.responseContent;
      } else if (response.statusCode == 401) {
        // JWT may be expired
        await AuthService.logout();
      }
      
      return null;
    } catch (e) {
      debugPrint('Chat error: $e');
      return null;
    }
  }
}