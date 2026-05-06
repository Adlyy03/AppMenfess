import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/menfess_model.dart';
import '../models/comment_model.dart';
import '../services/auth_service.dart';
import '../services/menfess_service.dart';
import '../services/reaction_service.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../services/bookmark_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final MenfessService _menfessService = MenfessService();
  final ReactionService _reactionService = ReactionService();
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();
  final BookmarkService _bookmarkService = BookmarkService();

  RealtimeChannel? _realtimeChannel;

  // ── Feed state ────────────────────────────────────────────────────────────
  List<MenfessModel> _menfessList = [];
  List<MenfessModel> get menfessList => _menfessList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  List<MenfessModel> _hotMenfess = [];
  List<MenfessModel> get hotMenfess => _hotMenfess;

  int _userPostCount = 0;
  int get userPostCount => _userPostCount;

  int _todayPostCount = 0;
  int get todayPostCount => _todayPostCount;

  int _userTotalLikes = 0;
  int get userTotalLikes => _userTotalLikes;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  String? _error;
  String? get error => _error;

  String? _userId;
  String? get userId => _userId;

  String? _lastSearch;

  // ── Like state ────────────────────────────────────────────────────────────
  /// menfessId → isLiked by current user
  final Map<String, bool> _likedMap = {};
  bool isLiked(String menfessId) => _likedMap[menfessId] ?? false;

  /// menfessId → optimistic like count offset (+1/-1)
  final Map<String, int> _likeCountDelta = {};

  /// menfessId → loading state for like button
  final Set<String> _likeLoading = {};
  bool isLikeLoading(String menfessId) => _likeLoading.contains(menfessId);

  // ── Bookmark state ────────────────────────────────────────────────────────
  /// menfessId → isBookmarked by current user
  final Map<String, bool> _bookmarkedMap = {};
  bool isBookmarked(String menfessId) => _bookmarkedMap[menfessId] ?? false;
  final Set<String> _bookmarkLoading = {};
  bool isBookmarkLoading(String menfessId) => _bookmarkLoading.contains(menfessId);

  // ── Comment state ─────────────────────────────────────────────────────────
  /// menfessId → list of loaded comments
  final Map<String, List<CommentModel>> _commentsMap = {};
  List<CommentModel> commentsFor(String menfessId) =>
      _commentsMap[menfessId] ?? [];

  /// menfessId → loading comments
  final Set<String> _commentLoading = {};
  bool isCommentLoading(String menfessId) =>
      _commentLoading.contains(menfessId);

  /// submitting comment
  bool _isSubmittingComment = false;
  bool get isSubmittingComment => _isSubmittingComment;

  // ── View tracking (in-memory de-dup) ─────────────────────────────────────
  final Set<String> _viewedInSession = {};

  // ── Notification state ───────────────────────────────────────────────────
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  bool _notifLoading = false;
  bool get notifLoading => _notifLoading;
  
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  // ── Auth ──────────────────────────────────────────────────────────────────
  void setUserId(String? id) {
    final oldId = _userId;
    _userId = id;
    
    if (id == null) {
      _likedMap.clear();
      _bookmarkedMap.clear();
      _likeCountDelta.clear();
    } else if (id != oldId && _menfessList.isNotEmpty) {
      // Reload liked/bookmarked status for existing list if user changed/logged in
      _loadLikedStatus(_menfessList);
    }
    notifyListeners();
  }

  Future<void> init() async {
    _userId = _authService.getCurrentUser()?.id;
    
    // Init Local Notifications
    await NotificationService.init();

    await Future.wait([
      fetchMenfess(),
      fetchHotToday(),
      fetchUserStats(),
      fetchNotifications(),
    ]);
    _setupRealtime();
  }

  void _setupRealtime() {
    final supabase = Supabase.instance.client;
    
    _realtimeChannel = supabase.channel('public:menfess')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'menfess',
        callback: (payload) {
          final newData = payload.newRecord;
          final id = newData['id'] as String;
          final newLikeCount = newData['like_count'] as int;
          final newCommentCount = newData['comment_count'] as int;

          // Update main feed list
          bool updated = false;
          _menfessList = _menfessList.map((m) {
            if (m.id == id) {
              updated = true;
              return m.copyWith(
                likeCount: newLikeCount,
                commentCount: newCommentCount,
              );
            }
            return m;
          }).toList();

          // Update hot/trending list
          _hotMenfess = _hotMenfess.map((m) {
            if (m.id == id) {
              updated = true;
              return m.copyWith(
                likeCount: newLikeCount,
                commentCount: newCommentCount,
              );
            }
            return m;
          }).toList();

          if (updated) {
            debugPrint('⚡ Realtime Update for $id: Likes $newLikeCount, Comments $newCommentCount');
            notifyListeners();
          }
        },
      );
    
    _realtimeChannel!.subscribe();

    // ── Notifications Channel ───────────────────────────────────────────
    if (_userId != null) {
      supabase.channel('public:notifications:$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId!,
          ),
          callback: (payload) {
            final notif = NotificationModel.fromMap(payload.newRecord);
            
            // Add to local list
            _notifications.insert(0, notif);
            
            // Trigger Local Notification
            NotificationService.showNotification(
              id: notif.hashCode,
              title: notif.title,
              body: notif.body,
            );
            
            notifyListeners();
          },
        ).subscribe();
    }
  }

  // ── Feed ──────────────────────────────────────────────────────────────────
  Future<void> fetchMenfess({String? search}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _menfessList = [];
    _lastSearch = search;
    notifyListeners();

    try {
      final result = await _menfessService.getMenfess(
        search: search,
        page: _currentPage,
      );
      _menfessList = result.data;
      _hasMore = result.hasMore;
      await _loadLikedStatus(_menfessList);
    } catch (e) {
      _error = 'Gagal mengambil data: $e';
      debugPrint('AppProvider.fetchMenfess error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHotToday() async {
    try {
      _hotMenfess = await _menfessService.getHotToday();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching hot today: $e');
    }
  }

  Future<void> fetchUserStats() async {
    if (_userId == null) return;
    try {
      final supabase = Supabase.instance.client;
      
      // Count posts
      final postsResponse = await supabase
          .from('menfess')
          .select('id')
          .eq('user_id', _userId!);
      _userPostCount = (postsResponse as List).length;

      // Count posts TODAY
      _todayPostCount = await _menfessService.postsTodayCount(_userId!);

      // Sum likes
      final likesResponse = await supabase
          .from('menfess')
          .select('like_count')
          .eq('user_id', _userId!);
      
      _userTotalLikes = (likesResponse as List).fold(0, (sum, item) => sum + (item['like_count'] as int));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
    }
  }

  Future<void> loadMoreMenfess() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _menfessService.getMenfess(
        search: _lastSearch,
        page: _currentPage + 1,
      );
      if (result.data.isNotEmpty) {
        _currentPage += 1;
        _menfessList.addAll(result.data);
        _hasMore = result.hasMore;
        await _loadLikedStatus(result.data);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _error = 'Gagal memuat lebih: $e';
      debugPrint('AppProvider.loadMoreMenfess error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMenfess(String message) async {
    if (_userId == null) return false;
    try {
      _todayPostCount = await _menfessService.postsTodayCount(_userId!);
      if (_todayPostCount >= 5) return false;
      await _menfessService.createMenfess(_userId!, message);
      _todayPostCount++;
      HapticFeedback.mediumImpact();
      await fetchMenfess();
      return true;
    } catch (e) {
      _error = 'Gagal membuat menfess: $e';
      debugPrint('AppProvider.createMenfess error: $e');
      return false;
    }
  }

  // ── Likes ─────────────────────────────────────────────────────────────────
  Future<void> _loadLikedStatus(List<MenfessModel> posts) async {
    if (_userId == null || posts.isEmpty) return;
    final ids = posts.map((m) => m.id).toList();
    final liked = await _reactionService.getLikedIds(_userId!, ids);
    final bookmarked = await _bookmarkService.getBookmarkedIds(_userId!, ids);
    for (final id in ids) {
      _likedMap[id] = liked.contains(id);
      _bookmarkedMap[id] = bookmarked.contains(id);
    }
  }

  /// Optimistic toggle: flips UI immediately, rolls back on error.
  Future<void> toggleLike(String menfessId) async {
    if (_userId == null) return;
    if (_likeLoading.contains(menfessId)) return;

    final wasLiked = _likedMap[menfessId] ?? false;

    // Optimistic update
    HapticFeedback.lightImpact();
    _likedMap[menfessId] = !wasLiked;
    _likeCountDelta[menfessId] =
        (_likeCountDelta[menfessId] ?? 0) + (wasLiked ? -1 : 1);
    _likeLoading.add(menfessId);
    notifyListeners();

    try {
      await _reactionService.toggleLike(menfessId, _userId!);
    } catch (e) {
      // Rollback
      _likedMap[menfessId] = wasLiked;
      _likeCountDelta[menfessId] =
          (_likeCountDelta[menfessId] ?? 0) + (wasLiked ? 1 : -1);
      debugPrint('AppProvider.toggleLike error: $e');
    } finally {
      _likeLoading.remove(menfessId);
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(String menfessId) async {
    if (_userId == null) return;
    if (_bookmarkLoading.contains(menfessId)) return;

    final wasBookmarked = _bookmarkedMap[menfessId] ?? false;

    // Optimistic update
    HapticFeedback.lightImpact();
    _bookmarkedMap[menfessId] = !wasBookmarked;
    _bookmarkLoading.add(menfessId);
    notifyListeners();

    try {
      debugPrint('📌 Toggling bookmark for $menfessId (User: $_userId)');
      final isNowBookmarked = await _bookmarkService.toggleBookmark(_userId!, menfessId);
      debugPrint('✅ Bookmark status for $menfessId: $isNowBookmarked');
      
      // Ensure local state matches DB result
      _bookmarkedMap[menfessId] = isNowBookmarked;
    } catch (e) {
      _bookmarkedMap[menfessId] = wasBookmarked;
      debugPrint('❌ Error toggling bookmark: $e');
    } finally {
      _bookmarkLoading.remove(menfessId);
      notifyListeners();
    }
  }

  /// Returns the displayed like count (base + optimistic delta).
  int likeCount(MenfessModel menfess) {
    final delta = _likeCountDelta[menfess.id] ?? 0;
    return (menfess.likeCount + delta).clamp(0, 999999);
  }

  Future<List<String>> getAllBookmarkedIds() async {
    if (_userId == null) return [];
    return await _bookmarkService.getAllBookmarkedIds(_userId!);
  }

  // ── Comments ──────────────────────────────────────────────────────────────
  Future<void> loadComments(String menfessId) async {
    if (_commentLoading.contains(menfessId)) return;
    _commentLoading.add(menfessId);
    
    // Gunakan microtask biar nggak bentrok sama proses build widget
    Future.microtask(() => notifyListeners());

    final list = await _commentService.getComments(menfessId);
    _commentsMap[menfessId] = list;

    _commentLoading.remove(menfessId);
    notifyListeners();
  }

  Future<bool> addComment(String menfessId, String text) async {
    if (_userId == null || text.trim().isEmpty) return false;
    _isSubmittingComment = true;
    notifyListeners();

    try {
      final comment =
          await _commentService.addComment(menfessId, _userId!, text.trim());

      // Append to local list immediately
      final existing = List<CommentModel>.from(_commentsMap[menfessId] ?? []);
      existing.add(comment);
      _commentsMap[menfessId] = existing;

      // Bump comment count in the feed item
      _menfessList = _menfessList.map((m) {
        if (m.id == menfessId) return m.copyWith(commentCount: m.commentCount + 1);
        return m;
      }).toList();

      _isSubmittingComment = false;
      HapticFeedback.lightImpact();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AppProvider.addComment error: $e');
      _isSubmittingComment = false;
      notifyListeners();
      return false;
    }
  }

  // ── Views ─────────────────────────────────────────────────────────────────
  /// Safe one-per-session view increment. Call when card becomes visible.
  Future<void> trackView(String menfessId) async {
    if (_userId == null) return;
    if (_viewedInSession.contains(menfessId)) return;
    _viewedInSession.add(menfessId);
    await _menfessService.incrementView(menfessId, _userId!);
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    if (_userId == null) return;
    _notifLoading = true;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(50);
      
      _notifications = (response as List)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _notifLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationsAsRead() async {
    if (_userId == null || _notifications.isEmpty) return;
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId!);
      
      // Update local state
      fetchNotifications();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  // ── Auth delegates ────────────────────────────────────────────────────────
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _authService.signInWithEmail(email, password);
      final user = _authService.getCurrentUser();
      if (user != null) {
        _userId = user.id;
        notifyListeners();
        unawaited(fetchMenfess());
      }
    } catch (e) {
      debugPrint('AppProvider.signInWithEmail error: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final response = await _authService.signUpWithEmail(email, password);
      final user = response.user;
      
      if (user != null) {
        await _userService.ensureUserExists(user.id, displayName: displayName);
        _userId = user.id;
        notifyListeners();
        unawaited(fetchMenfess());
      }
    } catch (e) {
      debugPrint('AppProvider.signUpWithEmail error: $e');
      rethrow;
    }
  }


  Future<void> signOut() async {
    try {
      _realtimeChannel?.unsubscribe();
      await _authService.signOut();
      _userId = null;
      _likedMap.clear();
      _bookmarkedMap.clear();
      _likeCountDelta.clear();
      _commentsMap.clear();
      _viewedInSession.clear();
      await fetchMenfess();
    } catch (e) {
      debugPrint('AppProvider.signOut error: $e');
    }
  }
}
