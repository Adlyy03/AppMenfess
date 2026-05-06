/// User role enum for role-based access control
/// 
/// Supports three roles:
/// - user: Regular user with no administrative privileges
/// - moderator: Admin with content moderation and user management permissions
/// - superAdmin: Full administrative access including role management
enum UserRole {
  user,
  moderator,
  superAdmin;

  /// Convert enum to database string value
  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.moderator:
        return 'moderator';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }

  /// Parse database string value to enum
  static UserRole fromString(String value) {
    switch (value) {
      case 'moderator':
        return UserRole.moderator;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }

  /// Check if role has admin privileges
  bool get isAdmin => this == UserRole.moderator || this == UserRole.superAdmin;

  /// Check if role is super admin
  bool get isSuperAdmin => this == UserRole.superAdmin;
}
