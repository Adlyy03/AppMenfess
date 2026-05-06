import 'package:flutter_test/flutter_test.dart';
import 'package:menfess_app/services/deep_link_service.dart';

void main() {
  group('DeepLinkService Tests', () {
    test('should parse menfess ID from app scheme URL', () {
      // Arrange
      const appSchemeUrl = 'menfess://post/abc123xyz';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(appSchemeUrl);

      // Assert
      expect(menfessId, equals('abc123xyz'));
    });

    test('should parse menfess ID from web URL', () {
      // Arrange
      const webUrl = 'https://menfess.skanic.com/p/abc123xyz';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(webUrl);

      // Assert
      expect(menfessId, equals('abc123xyz'));
    });

    test('should return null for invalid app scheme URL', () {
      // Arrange
      const invalidUrl = 'menfess://invalid/abc123xyz';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(invalidUrl);

      // Assert
      expect(menfessId, isNull);
    });

    test('should return null for invalid web URL', () {
      // Arrange
      const invalidUrl = 'https://menfess.skanic.com/invalid/abc123xyz';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(invalidUrl);

      // Assert
      expect(menfessId, isNull);
    });

    test('should return null for completely invalid URL', () {
      // Arrange
      const invalidUrl = 'not-a-url';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(invalidUrl);

      // Assert
      expect(menfessId, isNull);
    });

    test('should validate correct menfess links', () {
      // Arrange
      const validUrls = [
        'menfess://post/abc123',
        'https://menfess.skanic.com/p/xyz789',
      ];

      // Act & Assert
      for (final url in validUrls) {
        expect(DeepLinkService.isValidMenfessLink(url), isTrue);
      }
    });

    test('should reject invalid menfess links', () {
      // Arrange
      const invalidUrls = [
        'menfess://invalid/abc123',
        'https://other-domain.com/p/xyz789',
        'https://menfess.skanic.com/invalid/xyz789',
        'not-a-url',
        '',
      ];

      // Act & Assert
      for (final url in invalidUrls) {
        expect(DeepLinkService.isValidMenfessLink(url), isFalse);
      }
    });

    test('should handle URLs with query parameters', () {
      // Arrange
      const urlWithQuery = 'https://menfess.skanic.com/p/abc123?utm_source=share';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(urlWithQuery);

      // Assert
      expect(menfessId, equals('abc123'));
    });

    test('should handle URLs with fragments', () {
      // Arrange
      const urlWithFragment = 'https://menfess.skanic.com/p/abc123#comment-section';

      // Act
      final menfessId = DeepLinkService.parseMenfessId(urlWithFragment);

      // Assert
      expect(menfessId, equals('abc123'));
    });
  });
}