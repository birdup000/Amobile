// Models for AGiXT authentication
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthModel {
  final String email;
  final String token;

  AuthModel({
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'token': token,
      };
}

class AuthService {
  static const String JWT_KEY = 'jwt_token';
  static const String EMAIL_KEY = 'user_email';
  static String? _serverUrl;
  static String? _appUri;
  static String? _appName;

  // Initialize with environment variables
  static void init({required String serverUrl, required String appUri, required String appName}) {
    _serverUrl = serverUrl;
    _appUri = appUri;
    _appName = appName;
  }

  static String get serverUrl => _serverUrl ?? 'https://api.agixt.dev';
  static String get appUri => _appUri ?? 'https://agixt.dev';
  static String get appName => _appName ?? 'AGiXT';

  // Store JWT token
  static Future<void> storeJwt(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(JWT_KEY, token);
  }

  // Store user email
  static Future<void> storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(EMAIL_KEY, email);
  }

  // Get stored JWT token
  static Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(JWT_KEY);
  }

  // Get stored email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(EMAIL_KEY);
  }

  // Clear stored JWT token and email (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(JWT_KEY);
    await prefs.remove(EMAIL_KEY);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final jwt = await getJwt();
    return jwt != null && jwt.isNotEmpty;
  }

  // Login with email and MFA token
  static Future<String?> login(String email, String mfaCode) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/v1/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': mfaCode,
        }),
      );

      if (response.statusCode == 200) {
        // Extract JWT from login URL in response
        final responseBody = jsonDecode(response.body);
        final loginUrl = responseBody as String;
        
        if (loginUrl.contains('?token=')) {
          final parts = loginUrl.split('?token=');
          if (parts.length > 1) {
            final jwt = parts[1];
            await storeJwt(jwt);
            await storeEmail(email);
            return jwt;
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // Get the web URL with token for opening in browser
  static Future<String> getWebUrlWithToken() async {
    final jwt = await getJwt();
    return '$appUri?token=$jwt';
  }
}