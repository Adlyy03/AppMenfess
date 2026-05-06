import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class BookmarkService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> toggleBookmark(String userId, String menfessId) async {
    try {
      // Check if already bookmarked
      final existing = await _client
          .from('bookmarks')
          .select('id')
          .eq('user_id', userId)
          .eq('menfess_id', menfessId)
          .maybeSingle();

      if (existing != null) {
        // Remove bookmark
        await _client
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('menfess_id', menfessId);
        return false;
      } else {
        // Add bookmark
        await _client.from('bookmarks').insert({
          'user_id': userId,
          'menfess_id': menfessId,
        });
        return true;
      }
    } catch (e) {
      debugPrint('❌ BookmarkService.toggleBookmark ERROR: $e');
      rethrow;
    }
  }

  Future<List<String>> getBookmarkedIds(String userId, List<String> menfessIds) async {
    try {
      if (menfessIds.isEmpty) return [];
      
      final response = await _client
          .from('bookmarks')
          .select('menfess_id')
          .eq('user_id', userId)
          .inFilter('menfess_id', menfessIds);
      
      return (response as List).map((e) => e['menfess_id'].toString()).toList();
    } catch (e) {
      debugPrint('Error getting bookmarked IDs: $e');
      return [];
    }
  }

  Future<List<String>> getAllBookmarkedIds(String userId) async {
    try {
      final response = await _client
          .from('bookmarks')
          .select('menfess_id')
          .eq('user_id', userId);
      
      return (response as List).map((e) => e['menfess_id'].toString()).toList();
    } catch (e) {
      debugPrint('Error getting all bookmarked IDs: $e');
      return [];
    }
  }
}
