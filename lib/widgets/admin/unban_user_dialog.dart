import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/user_admin_model.dart';
import '../../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UNBAN USER DIALOG — Neo-Brutalism Style
// Dialog for unbanning a user with confirmation
// ─────────────────────────────────────────────────────────────────────────────

class UnbanUserDialog extends StatefulWidget {
  final UserAdminModel user;
  final AdminProvider adminProvider;

  const UnbanUserDialog({
    super.key,
    required this.user,
    required this.adminProvider,
  });

  @override
  State<UnbanUserDialog> createState() => _UnbanUserDialogState();
}

class _UnbanUserDialogState extends State<UnbanUserDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleUnban() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.adminProvider.unbanUser(widget.user.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User unbanned successfully',
              style: NeoBrutalismTheme.bodyBold(),
            ),
            backgroundColor: NeoBrutalismTheme.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = widget.adminProvider.error ?? 'Failed to unban user';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8)],
        ),
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
                      color: NeoBrutalismTheme.green,
                      border: Border.all(
                        color: NeoBrutalismTheme.black,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 24,
                      color: NeoBrutalismTheme.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'UNBAN USER',
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

              const SizedBox(height: 16),

              // Confirmation Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.yellow.withOpacity(0.3),
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: NeoBrutalismTheme.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This user will regain full access to the platform.',
                        style: NeoBrutalismTheme.body(),
                      ),
                    ),
                  ],
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
                    label: _isLoading ? 'UNBANNING...' : 'UNBAN USER',
                    color: NeoBrutalismTheme.green,
                    onTap: _isLoading ? null : _handleUnban,
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
