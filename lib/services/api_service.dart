import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://fuckthaturl.rf.gd/api';
  static const String apiKey = 'fturl_4255647ac6ea8038ce85d275b04a1259f10b2d3e';

  // Shorten URL
  static Future<Map<String, dynamic>> shortenUrl({
    required String url,
    String? customSlug,
    int? expiryDays,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shorten'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode({
          'url': url,
          if (customSlug != null && customSlug.isNotEmpty) 
            'custom_slug': customSlug,
          if (expiryDays != null) 'expiry_days': expiryDays,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}'
      };
    }
  }

  // Get link stats
  static Future<Map<String, dynamic>> getLinkStats(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$slug'),
        headers: {'X-API-Key': apiKey},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}'
      };
    }
  }

  // Get user stats
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/stats'),
        headers: {'X-API-Key': apiKey},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}'
      };
    }
  }

  // Delete link
  static Future<Map<String, dynamic>> deleteLink(String slug) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$slug'),
        headers: {'X-API-Key': apiKey},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}'
      };
    }
  }
}
