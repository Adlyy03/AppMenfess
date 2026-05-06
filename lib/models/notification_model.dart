class NotificationModel {
  final String id;
  final String userId;
  final String? actorId; // Made optional
  final String menfessId;
  final String type; // 'like', 'comment', 'bookmark'
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    this.actorId, // Made optional
    required this.menfessId,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      actorId: map['actor_id'], // Will be null if column doesn't exist
      menfessId: map['menfess_id'],
      type: map['type'],
      createdAt: DateTime.parse(map['created_at']),
      isRead: map['is_read'] ?? false,
    );
  }

  String get title {
    switch (type) {
      case 'like':
        return 'Seseorang menyukai menfess kamu!';
      case 'comment':
        return 'Ada komentar baru di menfess kamu!';
      case 'bookmark':
        return 'Menfess kamu disimpan oleh seseorang!';
      default:
        return 'Notifikasi Baru';
    }
  }

  String get body {
    final shortActor = actorId != null && actorId!.length > 4 
        ? actorId!.substring(0, 4) 
        : (actorId ?? 'XXXX');
    switch (type) {
      case 'like':
        return 'Anon#$shortActor memberikan love ❤️';
      case 'comment':
        return 'Anon#$shortActor membalas menfess kamu 💬';
      case 'bookmark':
        return 'Anon#$shortActor menyimpan menfess kamu 🔖';
      default:
        return 'Lihat detailnya sekarang.';
    }
  }
}
