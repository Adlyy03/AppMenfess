import 'menfess_model.dart';

/// Model for user-submitted reports about menfess posts
/// 
/// Supports report lifecycle: pending -> reviewing -> resolved/dismissed
class ReportModel {
  final String id;
  final String menfessId;
  final String reporterId;
  final String reason;
  final String? description;
  final String status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolutionNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields from joins
  final MenfessModel? menfess;
  final String? reporterDisplayName;
  final String? reviewerDisplayName;

  const ReportModel({
    required this.id,
    required this.menfessId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNote,
    required this.createdAt,
    required this.updatedAt,
    this.menfess,
    this.reporterDisplayName,
    this.reviewerDisplayName,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as String,
      menfessId: map['menfess_id'] as String,
      reporterId: map['reporter_id'] as String,
      reason: map['reason'] as String,
      description: map['description'] as String?,
      status: map['status'] as String,
      reviewedBy: map['reviewed_by'] as String?,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.tryParse(map['reviewed_at'].toString())
          : null,
      resolutionNote: map['resolution_note'] as String?,
      createdAt: DateTime.tryParse(map['created_at'].toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'].toString()) ??
          DateTime.now(),
      menfess: map['menfess'] != null
          ? MenfessModel.fromMap(map['menfess'] as Map<String, dynamic>)
          : null,
      reporterDisplayName: map['reporter_display_name'] as String?,
      reviewerDisplayName: map['reviewer_display_name'] as String?,
    );
  }
}
