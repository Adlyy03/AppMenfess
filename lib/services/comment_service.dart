import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/comment_model.dart';

class CommentService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all comments for a post, ordered oldest-first.
  Future<List<CommentModel>> getComments(String menfessId) async {
    try {
      final response = await _client
          .from('comments')
          .select()
          .eq('menfess_id', menfessId)
          .order('created_at', ascending: true);
      return (response as List)
          .map((e) => CommentModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CommentService.getComments error: $e');
      return [];
    }
  }

  /// Inserts a comment and atomically increments the comment_count.
  /// Returns the newly created [CommentModel] so UI can append it immediately.
  Future<CommentModel> addComment(
      String menfessId, String userId, String text) async {
    final inserted = await _client
        .from('comments')
        .insert({
          'menfess_id': menfessId,
          'user_id': userId,
          'text': text,
        })
        .select()
        .single();

    // Increment comment_count via RPC for atomic safety
    try {
      await _client.rpc('increment_comment',
          params: {'p_menfess_id': menfessId});
    } catch (e) {
      debugPrint('CommentService.addComment rpc error: $e');
      // Non-fatal: comment was saved, counter will sync on next fetch
    }

    return CommentModel.fromMap(inserted as Map<String, dynamic>);
  }
}
