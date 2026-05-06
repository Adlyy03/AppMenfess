/// Model for banned user records
/// 
/// Tracks user bans with optional expiration dates for temporary bans
class BannedUserModel {
  final String id;
  final String userId;
  final String bannedBy;
  final String reason;
  final DateTime bannedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? notes;

  // Populated fields from joins
  final String? userDisplayName;
  final String? bannedByDisplayName;

  const BannedUserModel({
    required this.id,
    required this.userId,
    required this.bannedBy,
    required this.reason,
    required this.bannedAt,
    this.expiresAt,
    required this.isActive,
    this.notes,
    this.userDisplayName,
    this.bannedByDisplayName,
  });

  factory BannedUserModel.fromMap(Map<String, dynamic> map) {
    return BannedUserModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bannedBy: map['banned_by'] as String,
      reason: map['reason'] as String,
      bannedAt: DateTime.tryParse(map['banned_at'].toString()) ??
          DateTime.now(),
      expiresAt: map['expires_at'] != null
          ? DateTime.tryParse(map['expires_at'].toString())
          : null,
      isActive: map['is_active'] as bool? ?? true,
      notes: map['notes'] as String?,
      userDisplayName: map['user_display_name'] as String?,
      bannedByDisplayName: map['banned_by_display_name'] as String?,
    );
  }

  /// Check if this is a permanent ban (no expiration date)
  bool get isPermanent => expiresAt == null;

  /// Check if this ban has expired
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
