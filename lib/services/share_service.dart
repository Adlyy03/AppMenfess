import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/menfess_model.dart';

class ShareService {
  static const String baseUrl = 'https://menfess.skanic.com';
  static const String appScheme = 'menfess';
  
  /// Generate shareable link for a menfess post
  static String generateShareLink(String menfessId) {
    return '$baseUrl/p/$menfessId';
  }
  
  /// Generate deep link for app-to-app sharing
  static String generateDeepLink(String menfessId) {
    return '$appScheme://post/$menfessId';
  }
  
  /// Share menfess with custom message
  static Future<void> shareMenfess(MenfessModel menfess) async {
    try {
      final link = generateShareLink(menfess.id);
      final preview = _generatePreviewText(menfess);
      
      await Share.share(
        '$preview\n\n🔗 $link',
        subject: 'Menfess SKANIC - Anonymous Confession',
      );
      
      // Track share analytics (optional)
      await _trackShare(menfess.id, 'general');
    } catch (e) {
      print('Error sharing: $e');
    }
  }
  
  /// Share to specific platform with optimized content
  static Future<void> shareToWhatsApp(MenfessModel menfess) async {
    try {
      final link = generateShareLink(menfess.id);
      final message = '''
🤫 *Menfess Anonymous*

"${_truncateMessage(menfess.message, 100)}"

💬 ${menfess.commentCount} komentar
❤️ ${menfess.likeCount} likes

Baca selengkapnya: $link

#MenfessSKANIC #Anonymous
''';
      
      await Share.share(message);
      await _trackShare(menfess.id, 'whatsapp');
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
    }
  }
  
  /// Copy link to clipboard
  static Future<void> copyLink(MenfessModel menfess) async {
    try {
      final link = generateShareLink(menfess.id);
      await Clipboard.setData(ClipboardData(text: link));
      await _trackShare(menfess.id, 'copy_link');
    } catch (e) {
      print('Error copying link: $e');
    }
  }
  
  /// Generate QR Code link (for offline sharing)
  static String generateQRLink(String menfessId) {
    final link = generateShareLink(menfessId);
    return 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(link)}';
  }
  
  // Private helper methods
  static String _generatePreviewText(MenfessModel menfess) {
    final truncated = _truncateMessage(menfess.message, 120);
    return '''
🤫 Menfess Anonymous

"$truncated"

💬 ${menfess.commentCount} • ❤️ ${menfess.likeCount} • 👀 ${menfess.viewCount}
''';
  }
  
  static String _truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }
  
  static Future<void> _trackShare(String menfessId, String platform) async {
    // TODO: Implement analytics tracking
    // Could use Firebase Analytics, Mixpanel, or custom analytics
    print('Share tracked: $menfessId via $platform');
  }
}