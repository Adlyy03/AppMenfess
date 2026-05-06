import 'package:flutter_test/flutter_test.dart';
import 'package:menfess_app/models/menfess_model.dart';

void main() {
  group('MenfessModel Tests', () {
    test('should create MenfessModel from valid map', () {
      // Arrange
      final map = {
        'id': 'test-id-123',
        'user_id': 'user-123',
        'message': 'Test menfess message',
        'like_count': 5,
        'view_count': 10,
        'comment_count': 3,
        'is_bookmarked': true,
        'created_at': '2024-01-01T10:00:00Z',
        'expires_at': '2024-01-02T10:00:00Z',
      };

      // Act
      final menfess = MenfessModel.fromMap(map);

      // Assert
      expect(menfess.id, equals('test-id-123'));
      expect(menfess.userId, equals('user-123'));
      expect(menfess.message, equals('Test menfess message'));
      expect(menfess.likeCount, equals(5));
      expect(menfess.viewCount, equals(10));
      expect(menfess.commentCount, equals(3));
      expect(menfess.isBookmarked, equals(true));
      expect(menfess.createdAt.year, equals(2024));
      expect(menfess.expiresAt.year, equals(2024));
    });

    test('should handle missing fields with defaults', () {
      // Arrange
      final map = {
        'id': 'test-id-123',
        'created_at': '2024-01-01T10:00:00Z',
      };

      // Act
      final menfess = MenfessModel.fromMap(map);

      // Assert
      expect(menfess.userId, equals(''));
      expect(menfess.message, equals(''));
      expect(menfess.likeCount, equals(0));
      expect(menfess.viewCount, equals(0));
      expect(menfess.commentCount, equals(0));
      expect(menfess.isBookmarked, equals(false));
    });

    test('should detect expired menfess', () {
      // Arrange - Create a menfess that expired 1 hour ago
      final now = DateTime.now().toUtc();
      final pastExpiry = now.subtract(const Duration(hours: 1));
      final pastCreated = pastExpiry.subtract(const Duration(hours: 24));
      
      final map = {
        'id': 'test-id-123',
        'created_at': pastCreated.toIso8601String(),
        'expires_at': pastExpiry.toIso8601String(),
      };

      // Act
      final menfess = MenfessModel.fromMap(map);

      // Assert
      expect(menfess.isExpired, equals(true));
    });

    test('should detect non-expired menfess', () {
      // Arrange - Create a menfess that expires in 1 hour
      final now = DateTime.now().toUtc();
      final futureExpiry = now.add(const Duration(hours: 1));
      
      final map = {
        'id': 'test-id-123',
        'created_at': now.toIso8601String(),
        'expires_at': futureExpiry.toIso8601String(),
      };

      // Act
      final menfess = MenfessModel.fromMap(map);

      // Assert
      expect(menfess.isExpired, equals(false));
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = MenfessModel(
        id: 'test-id',
        userId: 'user-id',
        message: 'Original message',
        likeCount: 5,
        viewCount: 10,
        commentCount: 3,
        isBookmarked: false,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      // Act
      final updated = original.copyWith(
        likeCount: 10,
        isBookmarked: true,
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.message, equals(original.message));
      expect(updated.likeCount, equals(10)); // Updated
      expect(updated.isBookmarked, equals(true)); // Updated
      expect(updated.viewCount, equals(original.viewCount)); // Unchanged
    });
  });
}