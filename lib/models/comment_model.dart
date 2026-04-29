class CommentModel {
  final String id;
  final String menfessId;
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.menfessId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      menfessId: map['menfess_id'] as String,
      userId: map['user_id'] as String,
      text: map['text'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'].toString()) ??
          DateTime.now(),
    );
  }
}
