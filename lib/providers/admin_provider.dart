import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../models/admin_stats_model.dart';
import '../models/report_model.dart';
import '../models/user_admin_model.dart';
import '../models/admin_log_model.dart';

/// Provider for admin dashboard functionality
/// 
/// Manages admin state, permissions, and actions including:
/// - Role-based access control
/// - Dashboard statistics
/// - Content moderation (delete menfess)
/// - User management (ban/unban, role changes)
/// - Report management (resolve/dismiss)
/// - Audit logging
/// - Real-time updates
class AdminProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── State ─────────────────────────────────────────────────────────────────
  UserRole? _currentUserRole;
  AdminStatsModel? _stats;
  List<ReportModel> _reports = [];
  List<UserAdminModel> _users = [];
  List<AdminLogModel> _logs = [];
  bool _isLoading = false;
  String? _error;

  // Realtime channels
  RealtimeChannel? _reportsChannel;
  RealtimeChannel? _logsChannel;

  // ── Getters ───────────────────────────────────────────────────────────────
  UserRole? get currentUserRole => _currentUserRole;
  bool get isAdmin => _currentUserRole?.isAdmin ?? false;
  bool get isSuperAdmin => _currentUserRole?.isSuperAdmin ?? false;
  AdminStatsModel? get stats => _stats;
  List<ReportModel> get reports => _reports;
  List<UserAdminModel> get users => _users;
  List<AdminLogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Initialization ────────────────────────────────────────────────────────

  /// Initialize admin provider and fetch user role
  /// 
  /// Preconditions:
  /// - User must be authenticated
  /// - Supabase client must be initialized
  /// 
  /// Postconditions:
  /// - _currentUserRole is set to user's role from database
  /// - If user is admin, stats are fetched
  /// - Realtime subscriptions are established for admin users
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user role
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      _currentUserRole = UserRole.fromString(response['role'] as String);

      // If admin, fetch initial data
      if (isAdmin) {
        await fetchStats();
        _setupRealtimeSubscriptions();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('AdminProvider.initialize error: $e');
    }
  }

  // ── Dashboard Statistics ──────────────────────────────────────────────────

  /// Fetch dashboard statistics
  /// 
  /// Preconditions:
  /// - User must be admin (moderator or super_admin)
  /// - Database view admin_stats must exist
  /// 
  /// Postconditions:
  /// - _stats contains current platform statistics
  /// - _error is null if successful, error message otherwise
  Future<void> fetchStats() async {
    if (!isAdmin) return;

    try {
      final response = await _supabase.from('admin_stats').select().single();

      _stats = AdminStatsModel.fromMap(response);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch stats: $e';
      notifyListeners();
      debugPrint('AdminProvider.fetchStats error: $e');
    }
  }

  // ── Content Moderation ────────────────────────────────────────────────────

  /// Delete a menfess post (admin action)
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - menfessId must be valid UUID
  /// - Menfess must exist in database
  /// 
  /// Postconditions:
  /// - Menfess is deleted from database
  /// - Admin action is logged in admin_logs table
  /// - Related data (reactions, comments, reports) are cascade deleted
  /// - Returns true if successful, false otherwise
  Future<bool> deleteMenfess(String menfessId, String reason) async {
    if (!isAdmin) return false;

    try {
      await _supabase.rpc('admin_delete_menfess', params: {
        'menfess_id': menfessId,
        'reason': reason,
      });

      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to delete menfess: $e';
      notifyListeners();
      debugPrint('AdminProvider.deleteMenfess error: $e');
      return false;
    }
  }

  // ── User Management ───────────────────────────────────────────────────────

  /// Ban a user
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - targetUserId must be valid UUID and exist
  /// - Target user cannot be super_admin (unless caller is super_admin)
  /// - expiresAt must be in future if provided
  /// 
  /// Postconditions:
  /// - User is marked as banned in users table
  /// - Ban record is created in banned_users table
  /// - Admin action is logged
  /// - Returns true if successful
  Future<bool> banUser({
    required String targetUserId,
    required String reason,
    DateTime? expiresAt,
    String? notes,
  }) async {
    if (!isAdmin) return false;

    try {
      await _supabase.rpc('admin_ban_user', params: {
        'target_user_id': targetUserId,
        'reason': reason,
        'expires_at': expiresAt?.toIso8601String(),
        'notes': notes,
      });

      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to ban user: $e';
      notifyListeners();
      debugPrint('AdminProvider.banUser error: $e');
      return false;
    }
  }

  /// Unban a user
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - targetUserId must be currently banned
  /// 
  /// Postconditions:
  /// - User is_banned flag set to false
  /// - Active ban record is deactivated
  /// - Admin action is logged
  Future<bool> unbanUser(String targetUserId) async {
    if (!isAdmin) return false;

    try {
      await _supabase.rpc('admin_unban_user', params: {
        'target_user_id': targetUserId,
      });

      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to unban user: $e';
      notifyListeners();
      debugPrint('AdminProvider.unbanUser error: $e');
      return false;
    }
  }

  /// Change user role
  /// 
  /// Preconditions:
  /// - User must be super_admin
  /// - targetUserId must exist
  /// - newRole must be valid UserRole
  /// - Cannot change own role
  /// 
  /// Postconditions:
  /// - Target user's role is updated
  /// - Admin action is logged
  Future<bool> changeUserRole(String targetUserId, UserRole newRole) async {
    if (!isSuperAdmin) return false;

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == targetUserId) {
      _error = 'Cannot change your own role';
      notifyListeners();
      return false;
    }

    try {
      await _supabase.rpc('admin_change_role', params: {
        'target_user_id': targetUserId,
        'new_role': newRole.value,
      });

      return true;
    } catch (e) {
      _error = 'Failed to change role: $e';
      notifyListeners();
      debugPrint('AdminProvider.changeUserRole error: $e');
      return false;
    }
  }

  /// Delete user account permanently
  /// 
  /// Preconditions:
  /// - User must be super_admin
  /// - targetUserId must exist
  /// - Cannot delete own account
  /// - Cannot delete other super_admin accounts
  /// 
  /// Postconditions:
  /// - User account is permanently deleted from auth.users
  /// - All user data is cascade deleted (menfess, comments, reactions, etc.)
  /// - Admin action is logged
  /// - Returns true if successful
  Future<bool> deleteUserAccount(String targetUserId, String reason) async {
    if (!isSuperAdmin) return false;

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == targetUserId) {
      _error = 'Cannot delete your own account';
      notifyListeners();
      return false;
    }

    try {
      await _supabase.rpc('admin_delete_user', params: {
        'target_user_id': targetUserId,
        'reason': reason,
      });

      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to delete user: $e';
      notifyListeners();
      debugPrint('AdminProvider.deleteUserAccount error: $e');
      return false;
    }
  }

  // ── Report Management ─────────────────────────────────────────────────────

  /// Resolve a report
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - reportId must exist
  /// - Report status must be 'pending' or 'reviewing'
  /// 
  /// Postconditions:
  /// - Report status updated to 'resolved'
  /// - reviewed_by and reviewed_at fields populated
  /// - resolution_note saved
  /// - Admin action logged
  Future<bool> resolveReport(String reportId, String resolutionNote) async {
    if (!isAdmin) return false;

    try {
      await _supabase.rpc('admin_resolve_report', params: {
        'report_id': reportId,
        'resolution_note': resolutionNote,
      });

      await fetchReports();
      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to resolve report: $e';
      notifyListeners();
      debugPrint('AdminProvider.resolveReport error: $e');
      return false;
    }
  }

  /// Dismiss a report
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - reportId must exist
  /// - Report status must be 'pending' or 'reviewing'
  /// 
  /// Postconditions:
  /// - Report status updated to 'dismissed'
  /// - reviewed_by and reviewed_at fields populated
  /// - Admin action logged
  Future<bool> dismissReport(String reportId) async {
    if (!isAdmin) return false;

    try {
      await _supabase.rpc('admin_dismiss_report', params: {
        'report_id': reportId,
      });

      await fetchReports();
      await fetchStats();
      return true;
    } catch (e) {
      _error = 'Failed to dismiss report: $e';
      notifyListeners();
      debugPrint('AdminProvider.dismissReport error: $e');
      return false;
    }
  }

  /// Fetch all reports with filters
  /// 
  /// Preconditions:
  /// - User must be admin
  /// 
  /// Postconditions:
  /// - _reports contains filtered list of reports
  /// - Reports are ordered by created_at DESC
  Future<void> fetchReports({String? status}) async {
    if (!isAdmin) return;
    
    // Prevent multiple simultaneous calls
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Build query with filter BEFORE executing
      dynamic query = _supabase
          .from('reports')
          .select('''
            *,
            menfess:menfess_id(*)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      query = query.order('created_at', ascending: false);

      final response = await query;
      final reportsList = (response as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Fetch display names separately
      for (var reportMap in reportsList) {
        // Fetch reporter display name
        if (reportMap['reporter_id'] != null) {
          try {
            final reporterData = await _supabase
                .from('users')
                .select('display_name')
                .eq('id', reportMap['reporter_id'])
                .maybeSingle();
            reportMap['reporter_display_name'] = reporterData?['display_name'];
          } catch (e) {
            debugPrint('Failed to fetch reporter name: $e');
          }
        }

        // Fetch reviewer display name
        if (reportMap['reviewed_by'] != null) {
          try {
            final reviewerData = await _supabase
                .from('users')
                .select('display_name')
                .eq('id', reportMap['reviewed_by'])
                .maybeSingle();
            reportMap['reviewer_display_name'] = reviewerData?['display_name'];
          } catch (e) {
            debugPrint('Failed to fetch reviewer name: $e');
          }
        }
      }

      _reports = reportsList.map((e) => ReportModel.fromMap(e)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch reports: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('AdminProvider.fetchReports error: $e');
    }
  }

  // ── User Management Queries ───────────────────────────────────────────────

  /// Fetch users with admin info
  /// 
  /// Preconditions:
  /// - User must be admin
  /// 
  /// Postconditions:
  /// - _users contains list of users with aggregated stats
  Future<void> fetchUsers({String? searchQuery, UserRole? roleFilter}) async {
    if (!isAdmin) return;
    
    // Prevent multiple simultaneous calls
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use RPC function to get users with aggregated stats
      final response = await _supabase.rpc('admin_get_users', params: {
        'search_query': searchQuery,
        'role_filter': roleFilter?.value,
      });

      _users = (response as List)
          .map((e) => UserAdminModel.fromMap(e as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch users: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('AdminProvider.fetchUsers error: $e');
    }
  }

  // ── Audit Logs ────────────────────────────────────────────────────────────

  /// Fetch admin logs
  /// 
  /// Preconditions:
  /// - User must be admin
  /// 
  /// Postconditions:
  /// - _logs contains recent admin actions
  Future<void> fetchLogs({String? actionFilter, int limit = 100}) async {
    if (!isAdmin) return;
    
    // Prevent multiple simultaneous calls
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Build query with filter BEFORE executing
      dynamic query = _supabase
          .from('admin_logs')
          .select('*');

      if (actionFilter != null) {
        query = query.eq('action', actionFilter);
      }

      query = query.order('created_at', ascending: false).limit(limit);

      final response = await query;
      final logsList = (response as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Fetch admin display names separately
      for (var logMap in logsList) {
        if (logMap['admin_id'] != null) {
          try {
            final adminData = await _supabase
                .from('users')
                .select('display_name')
                .eq('id', logMap['admin_id'])
                .maybeSingle();
            logMap['admin_display_name'] = adminData?['display_name'];
          } catch (e) {
            debugPrint('Failed to fetch admin name: $e');
          }
        }
      }

      _logs = logsList.map((e) => AdminLogModel.fromMap(e)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch logs: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('AdminProvider.fetchLogs error: $e');
    }
  }

  // ── Realtime Subscriptions ────────────────────────────────────────────────

  /// Setup realtime subscriptions for admin data
  /// 
  /// Preconditions:
  /// - User must be admin
  /// - Realtime must be enabled on tables
  /// 
  /// Postconditions:
  /// - Subscriptions established for reports, admin_logs
  /// - UI updates automatically when data changes
  void _setupRealtimeSubscriptions() {
    // Subscribe to reports changes
    _reportsChannel = _supabase.channel('admin_reports')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reports',
        callback: (payload) {
          debugPrint('⚡ Realtime: Reports table changed');
          fetchReports();
          fetchStats();
        },
      )
      ..subscribe();

    // Subscribe to admin logs
    _logsChannel = _supabase.channel('admin_logs')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'admin_logs',
        callback: (payload) {
          debugPrint('⚡ Realtime: New admin log entry');
          fetchLogs();
        },
      )
      ..subscribe();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _reportsChannel?.unsubscribe();
    _logsChannel?.unsubscribe();
    super.dispose();
  }
}
