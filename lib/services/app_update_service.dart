import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../models/app_version_model.dart';

/// Service for handling app updates via APK download
class AppUpdateService {
  static const String _versionCheckUrl = 'https://raw.githubusercontent.com/USERNAME/REPO/main/version.json';
  
  final Dio _dio = Dio();

  /// Check if there's a newer version available
  Future<AppVersionModel?> checkForUpdate() async {
    try {
      debugPrint('🔍 Checking for app updates...');
      
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.parse(packageInfo.buildNumber);
      
      debugPrint('📱 Current version: $currentVersion+$currentBuildNumber');
      
      // Fetch latest version from server
      final response = await http.get(Uri.parse(_versionCheckUrl));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final latestVersion = AppVersionModel.fromJson(jsonData);
        
        debugPrint('🌐 Latest version: ${latestVersion.version}+${latestVersion.buildNumber}');
        
        // Compare versions by build number (more reliable than version string)
        if (latestVersion.buildNumber > currentBuildNumber) {
          debugPrint('✅ Update available: ${latestVersion.version}');
          return latestVersion;
        } else {
          debugPrint('✅ App is up to date');
          return null;
        }
      } else {
        debugPrint('❌ Failed to check version: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      return null;
    }
  }

  /// Download and install APK
  Future<bool> downloadAndInstallApk({
    required String downloadUrl,
    required Function(double) onProgress,
    required VoidCallback onDownloadComplete,
  }) async {
    try {
      debugPrint('📥 Starting APK download from: $downloadUrl');
      
      // Request permissions
      final hasPermission = await _requestInstallPermission();
      if (!hasPermission) {
        debugPrint('❌ Install permission denied');
        return false;
      }
      
      // Get download directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('❌ Could not access storage directory');
        return false;
      }
      
      final filePath = '${directory.path}/app-update.apk';
      
      // Delete existing file if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Download APK with progress tracking
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            debugPrint('📥 Download progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );
      
      debugPrint('✅ Download completed: $filePath');
      onDownloadComplete();
      
      // Install APK
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        debugPrint('✅ APK installation initiated');
        return true;
      } else {
        debugPrint('❌ Failed to open APK: ${result.message}');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ Error downloading/installing APK: $e');
      return false;
    }
  }

  /// Request permission to install unknown sources
  Future<bool> _requestInstallPermission() async {
    try {
      // For Android 8.0+ (API 26+), we need REQUEST_INSTALL_PACKAGES permission
      if (Platform.isAndroid) {
        // Check if we can install unknown apps
        final status = await Permission.requestInstallPackages.status;
        
        if (status.isDenied) {
          final result = await Permission.requestInstallPackages.request();
          return result.isGranted;
        }
        
        return status.isGranted;
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting install permission: $e');
      return false;
    }
  }

  /// Get current app version info
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      debugPrint('❌ Error getting current version: $e');
      return 'Unknown';
    }
  }

  /// Compare version strings (fallback method)
  bool isNewerVersion(String currentVersion, String latestVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = latestVersion.split('.').map(int.parse).toList();
      
      // Pad shorter version with zeros
      while (current.length < latest.length) current.add(0);
      while (latest.length < current.length) latest.add(0);
      
      for (int i = 0; i < current.length; i++) {
        if (latest[i] > current[i]) return true;
        if (latest[i] < current[i]) return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error comparing versions: $e');
      return false;
    }
  }

  /// Clean up downloaded files
  Future<void> cleanupDownloadedFiles() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File('${directory.path}/app-update.apk');
        if (await file.exists()) {
          await file.delete();
          debugPrint('🧹 Cleaned up downloaded APK file');
        }
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up files: $e');
    }
  }
}