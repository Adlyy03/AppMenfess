import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/menfess_model.dart';
import '../core/constants.dart';

class MenfessService {
  final SupabaseClient _client = Supabase.instance.client;
  static const int pageSize = 10;

  Future<({List<MenfessModel> data, bool hasMore})> getMenfess({
    String? search,
    int page = 0,
  }) async {
    try {
      final offset = page * pageSize;
      
      final response = search != null && search.isNotEmpty
          ? await _client
              .from('menfess')
              .select()
              .ilike('message', '%$search%')
              .order('created_at', ascending: false)
              .range(offset, offset + pageSize - 1)
          : await _client
              .from('menfess')
              .select()
              .order('created_at', ascending: false)
              .range(offset, offset + pageSize - 1);

      final data = (response as List)
          .map((e) => MenfessModel.fromMap(e as Map<String, dynamic>))
          .where((m) => !m.isExpired)
          .toList();

      final hasMore = data.length == pageSize;
      return (data: data, hasMore: hasMore);
    } catch (e) {
      debugPrint('Error fetching menfess: $e');
      rethrow;
    }
  }

  Future<List<MenfessModel>> getHotToday() async {
    try {
      final start = DateTime.now().toUtc().copyWith(
          hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      final response = await _client
          .from('menfess')
          .select()
          .gte('created_at', start.toIso8601String())
          .order('like_count', ascending: false)
          .limit(10);

      return (response as List)
          .map((e) => MenfessModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching hot today: $e');
      return [];
    }
  }

  Future<void> createMenfess(String userId, String message) async {
    try {
      final expiresAt = DateTime.now()
          .toUtc()
          .add(Duration(hours: AppConstants.postExpiryHours));
      await _client.from('menfess').insert({
        'user_id': userId,
        'message': message,
        'like_count': 0,
        'view_count': 0,
        'comment_count': 0,
        'expires_at': expiresAt.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating menfess: $e');
      rethrow;
    }
  }

  Future<void> incrementView(String menfessId) async {
    try {
      await _client.rpc('increment_view', params: {'menfess_id': menfessId});
    } catch (e) {
      debugPrint('Error incrementing view: $e');
      // Don't rethrow - view count errors shouldn't break the app
    }
  }

  Future<void> toggleBookmark(String menfessId, bool current) async {
    try {
      await _client
          .from('menfess')
          .update({'is_bookmarked': !current})
          .eq('id', menfessId);
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      rethrow;
    }
  }

  Future<int> postsTodayCount(String userId) async {
    try {
      // Reset at 02:00 WIB (Local time)
      final now = DateTime.now();
      DateTime resetPoint;
      if (now.hour < 2) {
        resetPoint = DateTime(now.year, now.month, now.day, 2).subtract(const Duration(days: 1));
      } else {
        resetPoint = DateTime(now.year, now.month, now.day, 2);
      }
      final start = resetPoint.toUtc();
      
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
