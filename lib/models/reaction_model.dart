class ReactionModel {
  final String id;
  final String menfessId;
  final String userId;
  final String type; // 'like', 'heart', 'laugh', etc.

  ReactionModel({
    required this.id,
    required this.menfessId,
    required this.userId,
    required this.type,
  });

  factory ReactionModel.fromMap(Map<String, dynamic> map) {
    return ReactionModel(
      id: map['id'] as String,
      menfessId: map['menfess_id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String? ?? 'like',
    );
  }
}
