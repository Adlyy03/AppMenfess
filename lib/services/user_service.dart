import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sync current auth user to public users table.
  /// Uses upsert to avoid duplicate key errors on restart/re-login.
  /// Returns null if RLS blocks (will be lazy-created on post creation)
  Future<UserModel?> syncUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      await _client.from('users').upsert(
        {
          'id': user.id,
          'display_name': 'Anon#${user.id.substring(0, 5)}',
        },
        onConflict: 'id',
        ignoreDuplicates: true,
      );

      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromMap(data);
    } catch (e) {
      // If RLS blocks insert, return null - user will be created on first menfess
      if (e.toString().contains('row-level security')) {
        debugPrint('User sync blocked by RLS (expected for anonymous). Will lazy-create on post.');
        return null;
      }
      debugPrint('Error syncing user: $e');
      return null;
    }
  }

  /// Ensure user exists in database before operations
  /// Creates user row if it doesn't exist
  Future<void> ensureUserExists(String userId, {String? displayName}) async {
    try {
      // Try to get user
      final existing = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // If user doesn't exist, create it
      if (existing == null) {
        await _client.from('users').insert({
          'id': userId,
          'display_name': displayName ?? 'Anon#${userId.substring(0, 5)}',
        });
      }
    } catch (e) {
      if (e.toString().contains('row-level security')) {
        debugPrint('Cannot create user due to RLS. User operations may be limited.');
      } else {
        debugPrint('Error ensuring user exists: $e');
      }
    }
  }

  Future<int> postsTodayCount(String userId) async {
    try {
      final start = DateTime.now().toUtc().copyWith(
            hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      final response = await _client
          .from('menfess')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String());
      return (response as List).length;
    } catch (e) {
      debugPrint('Error fetching posts count: $e');
      return 0;
    }
  }
}
