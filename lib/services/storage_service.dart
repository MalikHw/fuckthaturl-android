import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _linksKey = 'saved_links';

  // Save a link
  static Future<void> saveLink(Map<String, dynamic> linkData) async {
    final prefs = await SharedPreferences.getInstance();
    final links = await getLinks();
    
    // Add or update link
    links.removeWhere((link) => link['slug'] == linkData['slug']);
    links.insert(0, linkData);
    
    await prefs.setString(_linksKey, jsonEncode(links));
  }

  // Get all links
  static Future<List<Map<String, dynamic>>> getLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final linksJson = prefs.getString(_linksKey);
    
    if (linksJson == null) {
      return [];
    }
    
    final List<dynamic> linksList = jsonDecode(linksJson);
    return linksList.cast<Map<String, dynamic>>();
  }

  // Delete a link
  static Future<void> deleteLink(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final links = await getLinks();
    
    links.removeWhere((link) => link['slug'] == slug);
    
    await prefs.setString(_linksKey, jsonEncode(links));
  }

  // Clear all links
  static Future<void> clearAllLinks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_linksKey);
  }
}
