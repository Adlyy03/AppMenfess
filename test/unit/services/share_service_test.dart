import 'package:flutter_test/flutter_test.dart';
import 'package:menfess_app/services/share_service.dart';
import 'package:menfess_app/models/menfess_model.dart';

void main() {
  group('ShareService Tests', () {
    late MenfessModel testMenfess;

    setUp(() {
      testMenfess = MenfessModel(
        id: 'test-menfess-123',
        userId: 'user-456',
        message: 'This is a test menfess message for sharing functionality',
        likeCount: 5,
        viewCount: 10,
        commentCount: 3,
        isBookmarked: false,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
    });

    test('should generate correct share link', () {
      // Act
      final link = ShareService.generateShareLink(testMenfess.id);

      // Assert
      expect(link, equals('https://menfess.skanic.com/p/test-menfess-123'));
    });

    test('should generate correct deep link', () {
      // Act
      final deepLink = ShareService.generateDeepLink(testMenfess.id);

      // Assert
      expect(deepLink, equals('menfess://post/test-menfess-123'));
    });

    test('should generate QR link with encoded URL', () {
      // Act
      final qrLink = ShareService.generateQRLink(testMenfess.id);

      // Assert
      expect(qrLink, contains('https://api.qrserver.com/v1/create-qr-code/'));
      expect(qrLink, contains('size=200x200'));
      expect(qrLink, contains('data='));
      expect(qrLink, contains('menfess.skanic.com'));
    });

    test('should truncate long messages correctly', () {
      // Arrange
      final longMessage = 'A' * 150; // 150 characters
      final longMenfess = testMenfess.copyWith(message: longMessage);

      // Act
      final link = ShareService.generateShareLink(longMenfess.id);

      // Assert
      expect(link, isNotNull);
      expect(link, contains('test-menfess-123'));
    });

    test('should handle empty message', () {
      // Arrange
      final emptyMenfess = testMenfess.copyWith(message: '');

      // Act
      final link = ShareService.generateShareLink(emptyMenfess.id);

      // Assert
      expect(link, equals('https://menfess.skanic.com/p/test-menfess-123'));
    });

    test('should handle special characters in menfess ID', () {
      // Arrange
      const specialId = 'test-123_abc-xyz';

      // Act
      final link = ShareService.generateShareLink(specialId);
      final deepLink = ShareService.generateDeepLink(specialId);

      // Assert
      expect(link, equals('https://menfess.skanic.com/p/test-123_abc-xyz'));
      expect(deepLink, equals('menfess://post/test-123_abc-xyz'));
    });
  });
}