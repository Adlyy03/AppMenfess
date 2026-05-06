import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/report_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT CARD — Neo-Brutalism Style
// Displays a user-submitted report with action buttons
// ─────────────────────────────────────────────────────────────────────────────

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;

  const ReportCard({
    super.key,
    required this.report,
    required this.onResolve,
    required this.onDismiss,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return NeoBrutalismTheme.yellow;
      case 'reviewing':
        return NeoBrutalismTheme.blue;
      case 'resolved':
        return NeoBrutalismTheme.green;
      case 'dismissed':
        return NeoBrutalismTheme.purple;
      default:
        return NeoBrutalismTheme.white;
    }
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'spam':
        return NeoBrutalismTheme.orange;
      case 'harassment':
        return NeoBrutalismTheme.red;
      case 'inappropriate':
        return NeoBrutalismTheme.purple;
      case 'misinformation':
        return NeoBrutalismTheme.blue;
      default:
        return NeoBrutalismTheme.yellow;
    }
  }

  String _formatReason(String reason) {
    return reason[0].toUpperCase() + reason.substring(1);
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);
    final reasonColor = _getReasonColor(report.reason);
    final canTakeAction = report.status == 'pending' || report.status == 'reviewing';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status + Reason badges
          Row(
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatStatus(report.status),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Reason Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: reasonColor,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatReason(report.reason),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              // Timestamp
              Text(
                DateFormat('dd MMM, HH:mm').format(report.createdAt),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reporter info
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: NeoBrutalismTheme.black,
              ),
              const SizedBox(width: 6),
              Text(
                'Reporter: ',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NeoBrutalismTheme.black,
                ),
              ),
              Text(
                report.reporterDisplayName ?? 'Anonymous',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black,
                ),
              ),
            ],
          ),

          // Description (if available)
          if (report.description != null && report.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.yellow.withOpacity(0.2),
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESCRIPTION',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.description!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reported Menfess (if available)
          if (report.menfess != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.white,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.article,
                        size: 14,
                        color: NeoBrutalismTheme.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'REPORTED POST',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.menfess!.message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          // Reviewer info (if reviewed)
          if (report.reviewedBy != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 16,
                  color: NeoBrutalismTheme.black,
                ),
                const SizedBox(width: 6),
                Text(
                  'Reviewed by: ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: NeoBrutalismTheme.black,
                  ),
                ),
                Text(
                  report.reviewerDisplayName ?? 'Unknown',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.black,
                  ),
                ),
              ],
            ),
          ],

          // Resolution note (if resolved)
          if (report.resolutionNote != null &&
              report.resolutionNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.green.withOpacity(0.2),
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESOLUTION NOTE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.resolutionNote!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons (only for pending/reviewing)
          if (canTakeAction) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'RESOLVE',
                    icon: Icons.check,
                    color: NeoBrutalismTheme.green,
                    onTap: onResolve,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'DISMISS',
                    icon: Icons.close,
                    color: NeoBrutalismTheme.orange,
                    onTap: onDismiss,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 44,
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: NeoBrutalismTheme.white,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
