/// Model for admin dashboard statistics
/// 
/// Aggregates platform metrics for the admin dashboard view
class AdminStatsModel {
  // User statistics
  final int totalUsers;
  final int usersToday;
  final int usersThisWeek;
  final int activeUsersToday;
  final int bannedUsersCount;

  // Content statistics
  final int totalMenfess;
  final int menfessToday;
  final int menfessThisWeek;

  // Engagement statistics
  final int totalReactions;
  final int reactionsToday;
  final int totalComments;
  final int commentsToday;

  // Report statistics
  final int pendingReports;
  final int reviewingReports;
  final int reportsToday;

  // Admin activity
  final int adminActionsToday;

  const AdminStatsModel({
    required this.totalUsers,
    required this.usersToday,
    required this.usersThisWeek,
    required this.activeUsersToday,
    required this.bannedUsersCount,
    required this.totalMenfess,
    required this.menfessToday,
    required this.menfessThisWeek,
    required this.totalReactions,
    required this.reactionsToday,
    required this.totalComments,
    required this.commentsToday,
    required this.pendingReports,
    required this.reviewingReports,
    required this.reportsToday,
    required this.adminActionsToday,
  });

  factory AdminStatsModel.fromMap(Map<String, dynamic> map) {
    return AdminStatsModel(
      totalUsers: (map['total_users'] as num?)?.toInt() ?? 0,
      usersToday: (map['users_today'] as num?)?.toInt() ?? 0,
      usersThisWeek: (map['users_this_week'] as num?)?.toInt() ?? 0,
      activeUsersToday: (map['active_users_today'] as num?)?.toInt() ?? 0,
      bannedUsersCount: (map['banned_users_count'] as num?)?.toInt() ?? 0,
      totalMenfess: (map['total_menfess'] as num?)?.toInt() ?? 0,
      menfessToday: (map['menfess_today'] as num?)?.toInt() ?? 0,
      menfessThisWeek: (map['menfess_this_week'] as num?)?.toInt() ?? 0,
      totalReactions: (map['total_reactions'] as num?)?.toInt() ?? 0,
      reactionsToday: (map['reactions_today'] as num?)?.toInt() ?? 0,
      totalComments: (map['total_comments'] as num?)?.toInt() ?? 0,
      commentsToday: (map['comments_today'] as num?)?.toInt() ?? 0,
      pendingReports: (map['pending_reports'] as num?)?.toInt() ?? 0,
      reviewingReports: (map['reviewing_reports'] as num?)?.toInt() ?? 0,
      reportsToday: (map['reports_today'] as num?)?.toInt() ?? 0,
      adminActionsToday: (map['admin_actions_today'] as num?)?.toInt() ?? 0,
    );
  }
}
