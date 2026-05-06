import 'user_role.dart';

/// Extended user model with admin-specific information and statistics
/// 
/// Used in the admin panel for user management with aggregated activity data
class UserAdminModel {
  final String id;
  final String? displayName;
  final UserRole role;
  final bool isBanned;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  // Aggregated statistics
  final int menfessCount;
  final int commentsCount;
  final int reactionsCount;
  final int reportsReceived;
  final int reportsMade;

  const UserAdminModel({
    required this.id,
    this.displayName,
    required this.role,
    required this.isBanned,
    this.lastLoginAt,
    required this.createdAt,
    required this.menfessCount,
    required this.commentsCount,
    required this.reactionsCount,
    required this.reportsReceived,
    required this.reportsMade,
  });

  factory UserAdminModel.fromMap(Map<String, dynamic> map) {
    return UserAdminModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'user'),
      isBanned: map['is_banned'] as bool? ?? false,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.tryParse(map['last_login_at'].toString())
          : null,
      createdAt: DateTime.tryParse(map['created_at'].toString()) ??
          DateTime.now(),
      menfessCount: (map['menfess_count'] as num?)?.toInt() ?? 0,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      reactionsCount: (map['reactions_count'] as num?)?.toInt() ?? 0,
      reportsReceived: (map['reports_received'] as num?)?.toInt() ?? 0,
      reportsMade: (map['reports_made'] as num?)?.toInt() ?? 0,
    );
  }
}
