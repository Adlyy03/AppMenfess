import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Handles like/reaction toggle with safe counter updates via DB functions.
class ReactionService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Returns true if [userId] has liked [menfessId].
  Future<bool> isLiked(String menfessId, String userId) async {
    try {
      final response = await _client
          .from('reactions')
          .select('id')
          .eq('menfess_id', menfessId)
          .eq('user_id', userId)
          .eq('type', 'like')
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('ReactionService.isLiked error: $e');
      return false;
    }
  }

  /// Fetches liked status for multiple posts at once.
  /// Returns a Set of menfessIds that the user has liked.
  Future<Set<String>> getLikedIds(String userId, List<String> menfessIds) async {
    if (menfessIds.isEmpty) return {};
    try {
      final response = await _client
          .from('reactions')
          .select('menfess_id')
          .eq('user_id', userId)
          .eq('type', 'like')
          .inFilter('menfess_id', menfessIds);
      return (response as List)
          .map((e) => e['menfess_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('ReactionService.getLikedIds error: $e');
      return {};
    }
  }

  /// Toggles like for a post. Returns new liked state.
  /// Uses RPC to ensure atomic counter update in DB.
  Future<bool> toggleLike(String menfessId, String userId) async {
    final alreadyLiked = await isLiked(menfessId, userId);
    try {
      if (alreadyLiked) {
        await _client
            .from('reactions')
            .delete()
            .eq('menfess_id', menfessId)
            .eq('user_id', userId);
        // Decrement count via RPC
        await _client.rpc('decrement_like', params: {'p_menfess_id': menfessId});
        return false;
      } else {
        await _client.from('reactions').upsert({
          'menfess_id': menfessId,
          'user_id': userId,
          'type': 'like',
        }, onConflict: 'menfess_id,user_id');
        // Increment count via RPC
        await _client.rpc('increment_like', params: {'p_menfess_id': menfessId});
        return true;
      }
    } catch (e) {
      debugPrint('ReactionService.toggleLike error: $e');
      rethrow;
    }
  }
}
