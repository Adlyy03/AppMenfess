import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/user_admin_model.dart';
import '../../models/user_role.dart';
import '../../providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CHANGE ROLE DIALOG — Neo-Brutalism Style
// Dialog for changing a user's role (super_admin only)
// ─────────────────────────────────────────────────────────────────────────────

class ChangeRoleDialog extends StatefulWidget {
  final UserAdminModel user;
  final AdminProvider adminProvider;

  const ChangeRoleDialog({
    super.key,
    required this.user,
    required this.adminProvider,
  });

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late UserRole _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  Future<void> _handleChangeRole() async {
    // Check if role has changed
    if (_selectedRole == widget.user.role) {
      setState(() {
        _errorMessage = 'Please select a different role';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.adminProvider.changeUserRole(
      widget.user.id,
      _selectedRole,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User role changed successfully',
              style: NeoBrutalismTheme.bodyBold(),
            ),
            backgroundColor: NeoBrutalismTheme.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = widget.adminProvider.error ?? 'Failed to change role';
        });
      }
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return NeoBrutalismTheme.purple;
      case UserRole.moderator:
        return NeoBrutalismTheme.blue;
      case UserRole.user:
        return NeoBrutalismTheme.yellow;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'SUPER ADMIN';
      case UserRole.moderator:
        return 'MODERATOR';
      case UserRole.user:
        return 'USER';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Full administrative access including role management';
      case UserRole.moderator:
        return 'Content moderation and user management permissions';
      case UserRole.user:
        return 'Regular user with no administrative privileges';
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
                        color: NeoBrutalismTheme.purple,
                        border: Border.all(
                          color: NeoBrutalismTheme.black,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 24,
                        color: NeoBrutalismTheme.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CHANGE ROLE',
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
                    color: NeoBrutalismTheme.purple.withOpacity(0.2),
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
                        'Current Role: ${_getRoleLabel(widget.user.role)}',
                        style: NeoBrutalismTheme.bodySmall(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Role Selection
                Text(
                  'SELECT NEW ROLE',
                  style: NeoBrutalismTheme.label(),
                ),
                const SizedBox(height: 12),

                // Role Options
                _RoleOption(
                  role: UserRole.user,
                  label: _getRoleLabel(UserRole.user),
                  description: _getRoleDescription(UserRole.user),
                  color: _getRoleColor(UserRole.user),
                  isSelected: _selectedRole == UserRole.user,
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.user;
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                _RoleOption(
                  role: UserRole.moderator,
                  label: _getRoleLabel(UserRole.moderator),
                  description: _getRoleDescription(UserRole.moderator),
                  color: _getRoleColor(UserRole.moderator),
                  isSelected: _selectedRole == UserRole.moderator,
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.moderator;
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                _RoleOption(
                  role: UserRole.superAdmin,
                  label: _getRoleLabel(UserRole.superAdmin),
                  description: _getRoleDescription(UserRole.superAdmin),
                  color: _getRoleColor(UserRole.superAdmin),
                  isSelected: _selectedRole == UserRole.superAdmin,
                  onTap: () {
                    setState(() {
                      _selectedRole = UserRole.superAdmin;
                      _errorMessage = null;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Warning Message
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
                        Icons.warning_amber,
                        color: NeoBrutalismTheme.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Role changes take effect immediately.',
                          style: NeoBrutalismTheme.body(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
                      label: _isLoading ? 'CHANGING...' : 'CHANGE ROLE',
                      color: NeoBrutalismTheme.purple,
                      onTap: _isLoading ? null : _handleChangeRole,
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
// ROLE OPTION COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _RoleOption extends StatefulWidget {
  final UserRole role;
  final String label;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.label,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleOption> createState() => _RoleOptionState();
}

class _RoleOptionState extends State<_RoleOption> {
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
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.only(
          top: _pressed ? 2 : 0,
          left: _pressed ? 2 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.color.withOpacity(0.3)
              : NeoBrutalismTheme.white,
          border: Border.all(
            color: widget.isSelected
                ? widget.color
                : NeoBrutalismTheme.black,
            width: widget.isSelected ? 3 : 2,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color
                    : NeoBrutalismTheme.white,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: widget.isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: NeoBrutalismTheme.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Role Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
