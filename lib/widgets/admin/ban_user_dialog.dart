import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/user_admin_model.dart';
import '../../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BAN USER DIALOG — Neo-Brutalism Style
// Dialog for banning a user with reason, expiration date, and notes
// ─────────────────────────────────────────────────────────────────────────────

class BanUserDialog extends StatefulWidget {
  final UserAdminModel user;
  final AdminProvider adminProvider;

  const BanUserDialog({
    super.key,
    required this.user,
    required this.adminProvider,
  });

  @override
  State<BanUserDialog> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends State<BanUserDialog> {
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expirationDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeoBrutalismTheme.blue,
              onPrimary: NeoBrutalismTheme.white,
              surface: NeoBrutalismTheme.white,
              onSurface: NeoBrutalismTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Also pick time
      if (mounted) {
        final timePicked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: NeoBrutalismTheme.blue,
                  onPrimary: NeoBrutalismTheme.white,
                  surface: NeoBrutalismTheme.white,
                  onSurface: NeoBrutalismTheme.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (timePicked != null) {
          setState(() {
            _expirationDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              timePicked.hour,
              timePicked.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _handleBan() async {
    // Validate reason
    if (_reasonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Ban reason is required';
      });
      return;
    }

    // Validate expiration date is in future
    if (_expirationDate != null && _expirationDate!.isBefore(DateTime.now())) {
      setState(() {
        _errorMessage = 'Expiration date must be in the future';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.adminProvider.banUser(
      targetUserId: widget.user.id,
      reason: _reasonController.text.trim(),
      expiresAt: _expirationDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User banned successfully',
              style: NeoBrutalismTheme.bodyBold(),
            ),
            backgroundColor: NeoBrutalismTheme.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = widget.adminProvider.error ?? 'Failed to ban user';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8)],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NeoBrutalismTheme.red,
                        border: Border.all(
                          color: NeoBrutalismTheme.black,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.block,
                        size: 24,
                        color: NeoBrutalismTheme.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'BAN USER',
                        style: NeoBrutalismTheme.heading2(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.yellow.withOpacity(0.3),
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.displayName ?? 'Anonymous',
                        style: NeoBrutalismTheme.bodyBold(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.user.id}',
                        style: NeoBrutalismTheme.bodySmall(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Ban Reason (Required)
                Text(
                  'BAN REASON *',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: NeoBrutalismTheme.inputDecoration(
                    hint: 'Enter reason for ban...',
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Expiration Date (Optional)
                Text(
                  'EXPIRATION DATE (Optional)',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _selectExpirationDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NeoBrutalismTheme.white,
                      border: Border.all(
                        color: NeoBrutalismTheme.black,
                        width: NeoBrutalismTheme.borderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: NeoBrutalismTheme.black,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _expirationDate == null
                                ? 'Permanent ban (no expiration)'
                                : 'Expires: ${_formatDateTime(_expirationDate!)}',
                            style: NeoBrutalismTheme.body(),
                          ),
                        ),
                        if (_expirationDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _expirationDate = null);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: NeoBrutalismTheme.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes (Optional)
                Text(
                  'NOTES (Optional)',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: NeoBrutalismTheme.inputDecoration(
                    hint: 'Additional notes...',
                  ),
                ),

                const SizedBox(height: 20),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NeoBrutalismTheme.red.withOpacity(0.2),
                      border: Border.all(
                        color: NeoBrutalismTheme.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: NeoBrutalismTheme.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: NeoBrutalismTheme.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _DialogButton(
                      label: 'CANCEL',
                      color: NeoBrutalismTheme.white,
                      onTap: _isLoading ? null : () => Navigator.pop(context, false),
                    ),
                    const SizedBox(width: 12),
                    _DialogButton(
                      label: _isLoading ? 'BANNING...' : 'BAN USER',
                      color: NeoBrutalismTheme.red,
                      onTap: _isLoading ? null : _handleBan,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? widget.color
              : widget.color.withOpacity(0.5),
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed || !isEnabled
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: widget.color == NeoBrutalismTheme.white
                ? NeoBrutalismTheme.black
                : NeoBrutalismTheme.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
