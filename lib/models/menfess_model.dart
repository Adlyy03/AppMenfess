class MenfessModel {
  final String id;
  final String userId;
  final String message;
  final int likeCount;
  final int viewCount;
  final int commentCount;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime expiresAt;

  const MenfessModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
    required this.isBookmarked,
    required this.createdAt,
    required this.expiresAt,
  });

  factory MenfessModel.fromMap(Map<String, dynamic> map) {
    String dateStr = map['created_at'].toString();
    // Force UTC if no timezone info is present to avoid Dart assuming local time
    if (!dateStr.contains('Z') && !dateStr.contains('+')) {
      dateStr += 'Z';
    }
    final created = DateTime.tryParse(dateStr) ?? DateTime.now();
    return MenfessModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      message: map['message'] as String? ?? '',
      likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
      viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
      commentCount: (map['comment_count'] as num?)?.toInt() ?? 0,
      isBookmarked: map['is_bookmarked'] as bool? ?? false,
      createdAt: created,
      expiresAt: () {
        String expStr = map['expires_at']?.toString() ?? '';
        if (expStr.isEmpty) return created.add(const Duration(hours: 24));
        if (!expStr.contains('Z') && !expStr.contains('+')) {
          expStr += 'Z';
        }
        return DateTime.tryParse(expStr) ?? created.add(const Duration(hours: 24));
      }(),
    );
  }

  MenfessModel copyWith({
    String? id,
    String? userId,
    String? message,
    int? likeCount,
    int? viewCount,
    int? commentCount,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return MenfessModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount ?? this.commentCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
