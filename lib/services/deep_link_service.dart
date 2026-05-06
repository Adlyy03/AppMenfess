import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  static const String _appScheme = 'menfess';
  static const String _webBaseUrl = 'https://menfess.skanic.com';
  
  /// Initialize deep link handling
  static void initialize() {
    // Listen for incoming deep links when app is already running
    _listenForIncomingLinks();
  }
  
  /// Handle deep link when app is launched from terminated state
  static Future<String?> getInitialLink() async {
    try {
      // This would typically use a plugin like app_links or uni_links
      // For now, we'll return null as placeholder
      return null;
    } catch (e) {
      print('Error getting initial link: $e');
      return null;
    }
  }
  
  /// Listen for incoming deep links when app is running
  static void _listenForIncomingLinks() {
    // This would typically use a plugin like app_links or uni_links
    // For now, this is a placeholder
  }
  
  /// Parse deep link and extract menfess ID
  static String? parseMenfessId(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Handle app scheme: menfess://post/{id}
      if (uri.scheme == _appScheme && uri.host == 'post') {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
      
      // Handle web URL: https://menfess.skanic.com/p/{id}
      if (uri.host == 'menfess.skanic.com' && uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'p') {
          return uri.pathSegments[1];
        }
      }
      
      return null;
    } catch (e) {
      print('Error parsing link: $e');
      return null;
    }
  }
  
  /// Open menfess in external browser if app is not installed
  static Future<void> openInBrowser(String menfessId) async {
    final url = '$_webBaseUrl/p/$menfessId';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening in browser: $e');
    }
  }
  
  /// Check if a URL is a valid menfess link
  static bool isValidMenfessLink(String url) {
    final menfessId = parseMenfessId(url);
    return menfessId != null && menfessId.isNotEmpty;
  }
}