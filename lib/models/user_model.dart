class UserModel {
  final String id;
  final String? displayName;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.displayName,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
      };
}
