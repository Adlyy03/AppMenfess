/// Model for admin action audit logs
/// 
/// Records all administrative actions for compliance and accountability
class AdminLogModel {
  final String id;
  final String adminId;
  final String action;
  final String targetType;
  final String targetId;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  // Populated fields from joins
  final String? adminDisplayName;

  const AdminLogModel({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.details,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    this.adminDisplayName,
  });

  factory AdminLogModel.fromMap(Map<String, dynamic> map) {
    return AdminLogModel(
      id: map['id'] as String,
      adminId: map['admin_id'] as String,
      action: map['action'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      details: map['details'] as Map<String, dynamic>?,
      ipAddress: map['ip_address'] as String?,
      userAgent: map['user_agent'] as String?,
      createdAt: DateTime.tryParse(map['created_at'].toString()) ??
          DateTime.now(),
      adminDisplayName: map['admin_display_name'] as String?,
    );
  }
}
