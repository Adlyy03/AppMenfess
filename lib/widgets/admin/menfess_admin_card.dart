import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menfess_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../core/utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MENFESS ADMIN CARD — Neo-Brutalism Style
// Admin-specific card for content moderation with delete functionality
// ─────────────────────────────────────────────────────────────────────────────

class MenfessAdminCard extends StatefulWidget {
  final MenfessModel menfess;
  final AdminProvider adminProvider;
  final AppProvider appProvider;
  final bool bulkSelectionMode;
  final bool isSelected;
  final VoidCallback onSelectionToggle;
  final VoidCallback onDeleted;

  const MenfessAdminCard({
    super.key,
    required this.menfess,
    required this.adminProvider,
    required this.appProvider,
    this.bulkSelectionMode = false,
    this.isSelected = false,
    required this.onSelectionToggle,
    required this.onDeleted,
  });

  @override
  State<MenfessAdminCard> createState() => _MenfessAdminCardState();
}

class _MenfessAdminCardState extends State<MenfessAdminCard> {
  bool _cardPressed = false;
  bool _isDeleting = false;

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(
        menfess: widget.menfess,
      ),
    );

    if (confirmed != true) return;

    // Show reason input dialog
    final reason = await _showReasonDialog();
    if (reason == null || reason.trim().isEmpty) return;

    // Perform deletion
    setState(() => _isDeleting = true);

    final success = await widget.adminProvider.deleteMenfess(
      widget.menfess.id,
      reason,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Menfess deleted successfully',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.green,
        ),
      );
      widget.onDeleted();
    } else {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.adminProvider.error ?? 'Failed to delete menfess',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.red,
        ),
      );
    }
  }

  Future<String?> _showReasonDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => _ReasonInputDialog(
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = DateTime.now().isAfter(widget.menfess.expiresAt);
    final isHot = widget.menfess.likeCount >= 10;

    // Show loading overlay if deleting
    if (_isDeleting) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white.withOpacity(0.5),
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: NeoBrutalismTheme.blue,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: widget.bulkSelectionMode
          ? null
          : (_) => setState(() => _cardPressed = true),
      onTapUp: widget.bulkSelectionMode
          ? null
          : (_) {
              setState(() => _cardPressed = false);
            },
      onTapCancel: () => setState(() => _cardPressed = false),
      onTap: widget.bulkSelectionMode ? widget.onSelectionToggle : null,
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.fromLTRB(
            16 + (_cardPressed ? 4 : 0),
            8 + (_cardPressed ? 4 : 0),
            16,
            8,
          ),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? NeoBrutalismTheme.yellow
                : (isHot ? NeoBrutalismTheme.red : NeoBrutalismTheme.white),
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidth,
            ),
            boxShadow: _cardPressed ? [] : [NeoBrutalismTheme.hardShadow()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              Row(
                children: [
                  // Selection Checkbox (shown in bulk mode)
                  if (widget.bulkSelectionMode) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? NeoBrutalismTheme.black
                            : NeoBrutalismTheme.white,
                        border: Border.all(
                          color: NeoBrutalismTheme.black,
                          width: NeoBrutalismTheme.borderWidthThin,
                        ),
                      ),
                      child: widget.isSelected
                          ? const Icon(
                              Icons.check,
                              size: 20,
                              color: NeoBrutalismTheme.yellow,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                  ],
                  _AnonAvatar(isHot: isHot),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ANON#${widget.menfess.userId.length >= 4 ? widget.menfess.userId.substring(0, 4) : widget.menfess.userId}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isHot
                                    ? NeoBrutalismTheme.white
                                    : NeoBrutalismTheme.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isHot) ...[
                              const SizedBox(width: 8),
                              _HotBadge(),
                            ],
                          ],
                        ),
                        Text(
                          timeAgo(widget.menfess.createdAt),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isHot
                                ? NeoBrutalismTheme.white.withOpacity(0.8)
                                : NeoBrutalismTheme.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ExpiryBadge(menfess: widget.menfess, isHot: isHot),
                ],
              ),
              const SizedBox(height: 14),

              // ── Message ──────────────────────────────────
              Text(
                widget.menfess.message,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: isHot
                      ? NeoBrutalismTheme.white
                      : NeoBrutalismTheme.black,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // ── Stats Row ────────────────────────────────
              Row(
                children: [
                  _StatBadge(
                    icon: Icons.favorite,
                    count: widget.menfess.likeCount,
                    isHot: isHot,
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    icon: Icons.chat_bubble,
                    count: widget.menfess.commentCount,
                    isHot: isHot,
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    icon: Icons.visibility,
                    count: widget.menfess.viewCount,
                    isHot: isHot,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                height: 3,
                color: isHot
                    ? NeoBrutalismTheme.white.withOpacity(0.3)
                    : NeoBrutalismTheme.black.withOpacity(0.2),
              ),
              const SizedBox(height: 14),

              // ── Admin Actions ────────────────────────────
              if (!widget.bulkSelectionMode)
                Row(
                  children: [
                    Expanded(
                      child: _AdminActionButton(
                        label: 'DELETE',
                        icon: Icons.delete,
                        color: NeoBrutalismTheme.red,
                        onTap: _showDeleteConfirmation,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AnonAvatar extends StatelessWidget {
  final bool isHot;
  const _AnonAvatar({this.isHot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isHot ? NeoBrutalismTheme.yellow : NeoBrutalismTheme.blue,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidthThin,
        ),
      ),
      child: Icon(
        isHot ? Icons.whatshot : Icons.person,
        size: 24,
        color: NeoBrutalismTheme.black,
      ),
    );
  }
}

class _HotBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.whatshot, size: 12, color: NeoBrutalismTheme.black),
          const SizedBox(width: 4),
          Text(
            'HOT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final MenfessModel menfess;
  final bool isHot;
  const _ExpiryBadge({required this.menfess, this.isHot = false});

  @override
  Widget build(BuildContext context) {
    final remaining = menfess.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    final isUrgent = remaining.inHours < 3;
    final label = remaining.inHours < 1
        ? '${remaining.inMinutes}M'
        : '${remaining.inHours}H';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? NeoBrutalismTheme.orange
            : (isHot ? NeoBrutalismTheme.black : NeoBrutalismTheme.yellow),
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: isUrgent
                ? NeoBrutalismTheme.white
                : (isHot ? NeoBrutalismTheme.white : NeoBrutalismTheme.black),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isUrgent
                  ? NeoBrutalismTheme.white
                  : (isHot ? NeoBrutalismTheme.white : NeoBrutalismTheme.black),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isHot;

  const _StatBadge({
    required this.icon,
    required this.count,
    this.isHot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHot ? NeoBrutalismTheme.black : NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHot
                ? NeoBrutalismTheme.white
                : NeoBrutalismTheme.black.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHot
                  ? NeoBrutalismTheme.white
                  : NeoBrutalismTheme.black.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _AdminActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AdminActionButton> createState() => _AdminActionButtonState();
}

class _AdminActionButtonState extends State<_AdminActionButton> {
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
        padding: EdgeInsets.fromLTRB(
          16 + (_pressed ? 3 : 0),
          12 + (_pressed ? 3 : 0),
          16,
          12,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: NeoBrutalismTheme.white,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE CONFIRMATION DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final MenfessModel menfess;

  const _DeleteConfirmDialog({
    required this.menfess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DELETE MENFESS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.yellow.withOpacity(0.3),
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
              ),
              child: Text(
                menfess.message,
                style: NeoBrutalismTheme.bodySmall(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete this menfess? This action cannot be undone.',
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: 'CANCEL',
                  color: NeoBrutalismTheme.white,
                  textColor: NeoBrutalismTheme.black,
                  onTap: () => Navigator.pop(context, false),
                ),
                const SizedBox(width: 12),
                _DialogButton(
                  label: 'CONTINUE',
                  color: NeoBrutalismTheme.red,
                  textColor: NeoBrutalismTheme.white,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REASON INPUT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _ReasonInputDialog extends StatelessWidget {
  final TextEditingController controller;

  const _ReasonInputDialog({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DELETION REASON',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please provide a reason for deleting this menfess:',
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: NeoBrutalismTheme.inputDecoration(
                hint: 'e.g., Spam, Inappropriate content, Harassment...',
              ),
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: 'CANCEL',
                  color: NeoBrutalismTheme.white,
                  textColor: NeoBrutalismTheme.black,
                  onTap: () => Navigator.pop(context, null),
                ),
                const SizedBox(width: 12),
                _DialogButton(
                  label: 'DELETE',
                  color: NeoBrutalismTheme.red,
                  textColor: NeoBrutalismTheme.white,
                  onTap: () => Navigator.pop(context, controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
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
        padding: EdgeInsets.fromLTRB(
          16 + (_pressed ? 2 : 0),
          10 + (_pressed ? 2 : 0),
          16,
          10,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: widget.textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
