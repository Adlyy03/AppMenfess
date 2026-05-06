import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/user_admin_model.dart';
import '../../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DELETE USER DIALOG — Neo-Brutalism Style
// Dialog for permanently deleting a user account (Super Admin only)
// ─────────────────────────────────────────────────────────────────────────────

class DeleteUserDialog extends StatefulWidget {
  final UserAdminModel user;
  final AdminProvider adminProvider;

  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.adminProvider,
  });

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  final _reasonController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    // Validate reason
    if (_reasonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Deletion reason is required';
      });
      return;
    }

    // Validate confirmation
    final expectedConfirm = 'DELETE ${widget.user.displayName ?? 'USER'}';
    if (_confirmController.text.trim() != expectedConfirm) {
      setState(() {
        _errorMessage = 'Confirmation text does not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.adminProvider.deleteUserAccount(
      widget.user.id,
      _reasonController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User account deleted permanently',
              style: NeoBrutalismTheme.bodyBold(),
            ),
            backgroundColor: NeoBrutalismTheme.red,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = widget.adminProvider.error ?? 'Failed to delete user';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmText = 'DELETE ${widget.user.displayName ?? 'USER'}';

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
                        Icons.delete_forever,
                        size: 24,
                        color: NeoBrutalismTheme.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DELETE USER',
                        style: NeoBrutalismTheme.heading2(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Warning Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.red.withOpacity(0.2),
                    border: Border.all(
                      color: NeoBrutalismTheme.red,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: NeoBrutalismTheme.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PERMANENT ACTION',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: NeoBrutalismTheme.red,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This will PERMANENTLY delete the user account and ALL associated data:',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: NeoBrutalismTheme.black,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _WarningItem('• All menfess posts'),
                      _WarningItem('• All comments'),
                      _WarningItem('• All reactions'),
                      _WarningItem('• All bookmarks'),
                      _WarningItem('• User profile data'),
                      _WarningItem('• Authentication account'),
                      const SizedBox(height: 12),
                      Text(
                        'THIS CANNOT BE UNDONE!',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.red,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                        'TARGET USER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.user.displayName ?? 'Anonymous',
                        style: NeoBrutalismTheme.bodyBold(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${widget.user.role.value}',
                        style: NeoBrutalismTheme.bodySmall(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posts: ${widget.user.menfessCount} | Comments: ${widget.user.commentsCount}',
                        style: NeoBrutalismTheme.bodySmall(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Deletion Reason (Required)
                Text(
                  'DELETION REASON *',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: NeoBrutalismTheme.inputDecoration(
                    hint: 'Why is this account being deleted?',
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Confirmation Input (Required)
                Text(
                  'TYPE TO CONFIRM *',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.yellow.withOpacity(0.2),
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Type exactly: $confirmText',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NeoBrutalismTheme.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmController,
                  decoration: NeoBrutalismTheme.inputDecoration(
                    hint: confirmText,
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
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
                      label: _isLoading ? 'DELETING...' : 'DELETE PERMANENTLY',
                      color: NeoBrutalismTheme.red,
                      onTap: _isLoading ? null : _handleDelete,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// WARNING ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _WarningItem extends StatelessWidget {
  final String text;

  const _WarningItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: NeoBrutalismTheme.black,
          height: 1.5,
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
          color: isEnabled ? widget.color : widget.color.withOpacity(0.5),
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
