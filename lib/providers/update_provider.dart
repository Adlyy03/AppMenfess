import 'package:flutter/material.dart';
import '../models/app_version_model.dart';
import '../services/app_update_service.dart';

/// Provider for managing app update state
class UpdateProvider extends ChangeNotifier {
  final AppUpdateService _updateService = AppUpdateService();

  // State
  AppVersionModel? _availableUpdate;
  bool _isCheckingUpdate = false;
  bool _hasCheckedToday = false;
  String? _error;
  DateTime? _lastCheckTime;

  // Getters
  AppVersionModel? get availableUpdate => _availableUpdate;
  bool get isCheckingUpdate => _isCheckingUpdate;
  bool get hasUpdateAvailable => _availableUpdate != null;
  bool get hasCheckedToday => _hasCheckedToday;
  String? get error => _error;
  DateTime? get lastCheckTime => _lastCheckTime;

  /// Check for updates (can be called manually or automatically)
  Future<void> checkForUpdates({bool forceCheck = false}) async {
    // Don't check if already checking
    if (_isCheckingUpdate) return;

    // Don't check if already checked today (unless forced)
    if (_hasCheckedToday && !forceCheck) {
      debugPrint('📱 Update already checked today, skipping...');
      return;
    }

    try {
      _isCheckingUpdate = true;
      _error = null;
      notifyListeners();

      debugPrint('🔍 Checking for app updates...');
      
      final updateInfo = await _updateService.checkForUpdate();
      
      _availableUpdate = updateInfo;
      _lastCheckTime = DateTime.now();
      _hasCheckedToday = true;
      
      if (updateInfo != null) {
        debugPrint('✅ Update available: ${updateInfo.version}');
      } else {
        debugPrint('✅ No updates available');
      }
      
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error checking for updates: $e');
    } finally {
      _isCheckingUpdate = false;
      notifyListeners();
    }
  }

  /// Dismiss current update notification
  void dismissUpdate() {
    _availableUpdate = null;
    notifyListeners();
    debugPrint('📱 Update notification dismissed');
  }

  /// Reset check status (for testing or manual refresh)
  void resetCheckStatus() {
    _hasCheckedToday = false;
    _lastCheckTime = null;
    _error = null;
    notifyListeners();
    debugPrint('📱 Update check status reset');
  }

  /// Get current app version
  Future<String> getCurrentVersion() async {
    return await _updateService.getCurrentVersion();
  }

  /// Clean up downloaded files
  Future<void> cleanupFiles() async {
    await _updateService.cleanupDownloadedFiles();
  }

  /// Auto-check for updates (called on app start)
  Future<void> autoCheckForUpdates() async {
    // Only auto-check once per day
    if (_lastCheckTime != null) {
      final now = DateTime.now();
      final lastCheck = _lastCheckTime!;
      final daysSinceLastCheck = now.difference(lastCheck).inDays;
      
      if (daysSinceLastCheck < 1) {
        debugPrint('📱 Auto-check skipped: Last check was ${daysSinceLastCheck} days ago');
        return;
      }
    }

    // Delay auto-check to not interfere with app startup
    await Future.delayed(const Duration(seconds: 3));
    await checkForUpdates();
  }

  /// Check if update is critical/forced
  bool get isUpdateCritical => _availableUpdate?.forceUpdate ?? false;

  /// Get update description
  String? get updateDescription => _availableUpdate?.description;

  /// Get update version
  String? get updateVersion => _availableUpdate?.version;

  /// Get update URL
  String? get updateUrl => _availableUpdate?.url;
}