import 'dart:convert';
import 'package:crypto/crypto.dart';

class GravatarUtils {
  /// Returns the Gravatar URL for the given email address
  /// Size parameter determines the size of the image (default is 80px)
  /// Default parameter is the fallback image URL when no Gravatar is found
  static String getGravatarUrl(String email,
      {int size = 80, String? defaultImage}) {
    // Trim and lowercase the email
    final cleanEmail = email.trim().toLowerCase();

    // Generate MD5 hash of the email
    final bytes = utf8.encode(cleanEmail);
    final hash = md5.convert(bytes).toString();

    // Construct the Gravatar URL
    var url = 'https://www.gravatar.com/avatar/$hash?s=$size';

    // Add default image parameter if provided
    if (defaultImage != null) {
      url += '&d=${Uri.encodeComponent(defaultImage)}';
    }

    return url;
  }
}
