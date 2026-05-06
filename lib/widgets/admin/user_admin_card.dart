import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/neo_brutalism_theme.dart';
import '../../models/user_admin_model.dart';
import '../../models/user_role.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USER ADMIN CARD WIDGET — Neo-Brutalism Style
// Displays user information, statistics, and action buttons for admin management
// ─────────────────────────────────────────────────────────────────────────────

class UserAdminCard extends StatefulWidget {
  final UserAdminModel user;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onBan;
  final VoidCallback? onUnban;
  final VoidCallback? onChangeRole;
  final VoidCallback? onDelete;

  const UserAdminCard({
    super.key,
    required this.user,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onBan,
    this.onUnban,
    this.onChangeRole,
    this.onDelete,
  });

  @override
  State<UserAdminCard> createState() => _UserAdminCardState();
}

class _UserAdminCardState extends State<UserAdminCard> {
  bool _pressed = false;

  Color _getRoleColor() {
    switch (widget.user.role) {
      case UserRole.superAdmin:
        return NeoBrutalismTheme.purple;
      case UserRole.moderator:
        return NeoBrutalismTheme.blue;
      case UserRole.user:
        return NeoBrutalismTheme.yellow;
    }
  }

  String _getRoleLabel() {
    switch (widget.user.role) {
      case UserRole.superAdmin:
        return 'SUPER ADMIN';
      case UserRole.moderator:
        return 'MODERATOR';
      case UserRole.user:
        return 'USER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? NeoBrutalismTheme.yellow.withOpacity(0.3)
              : NeoBrutalismTheme.white,
          border: Border.all(
            color: widget.isSelected
                ? NeoBrutalismTheme.yellow
                : NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Display Name, Role Badge, Ban Status
              Row(
                children: [
                  // Selection Checkbox
                  if (widget.isSelectionMode) ...[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? NeoBrutalismTheme.yellow
                            : NeoBrutalismTheme.white,
                        border: Border.all(
                          color: NeoBrutalismTheme.black,
                          width: 2,
                        ),
                      ),
                      child: widget.isSelected
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: NeoBrutalismTheme.black,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Display Name
                  Expanded(
                    child: Text(
                      widget.user.displayName ?? 'Anonymous',
                      style: NeoBrutalismTheme.heading3(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Role Badge
                  _RoleBadge(
                    label: _getRoleLabel(),
                    color: _getRoleColor(),
                  ),

                  // Ban Status Badge
                  if (widget.user.isBanned) ...[
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: 'BANNED',
                      color: NeoBrutalismTheme.red,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // User ID and Last Login
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${widget.user.id.substring(0, 8)}...',
                      style: NeoBrutalismTheme.bodySmall(),
                    ),
                  ),
                  if (widget.user.lastLoginAt != null)
                    Text(
                      'Last login: ${timeago.format(widget.user.lastLoginAt!)}',
                      style: NeoBrutalismTheme.bodySmall(),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Statistics Grid
              _StatisticsGrid(user: widget.user),

              const SizedBox(height: 16),

              // Action Buttons
              if (!widget.isSelectionMode) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            // Ban/Unban Button
            if (widget.user.isBanned)
              Expanded(
                child: _ActionButton(
                  label: 'UNBAN',
                  icon: Icons.check_circle,
                  color: NeoBrutalismTheme.green,
                  onTap: widget.onUnban,
                ),
              )
            else
              Expanded(
                child: _ActionButton(
                  label: 'BAN',
                  icon: Icons.block,
                  color: NeoBrutalismTheme.red,
                  onTap: widget.onBan,
                ),
              ),

            // Change Role Button (super_admin only)
            if (widget.onChangeRole != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'CHANGE ROLE',
                  icon: Icons.admin_panel_settings,
                  color: NeoBrutalismTheme.purple,
                  onTap: widget.onChangeRole,
                ),
              ),
            ],
          ],
        ),

        // Delete Button (super_admin only)
        if (widget.onDelete != null) ...[
          const SizedBox(height: 12),
          _ActionButton(
            label: 'DELETE ACCOUNT',
            icon: Icons.delete_forever,
            color: NeoBrutalismTheme.red,
            onTap: widget.onDelete,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATISTICS GRID COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _StatisticsGrid extends StatelessWidget {
  final UserAdminModel user;

  const _StatisticsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Posts',
                  value: user.menfessCount,
                  icon: Icons.article,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: NeoBrutalismTheme.black,
              ),
              Expanded(
                child: _StatItem(
                  label: 'Comments',
                  value: user.commentsCount,
                  icon: Icons.comment,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: NeoBrutalismTheme.black,
              ),
              Expanded(
                child: _StatItem(
                  label: 'Reactions',
                  value: user.reactionsCount,
                  icon: Icons.favorite,
                ),
              ),
            ],
          ),
          Container(
            height: 2,
            color: NeoBrutalismTheme.black,
          ),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Reports Made',
                  value: user.reportsMade,
                  icon: Icons.flag,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: NeoBrutalismTheme.black,
              ),
              Expanded(
                child: _StatItem(
                  label: 'Reports Received',
                  value: user.reportsReceived,
                  icon: Icons.warning,
                  isWarning: user.reportsReceived > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT ITEM COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final bool isWarning;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? NeoBrutalismTheme.red : NeoBrutalismTheme.black,
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isWarning ? NeoBrutalismTheme.red : NeoBrutalismTheme.black,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NeoBrutalismTheme.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE BADGE COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: EdgeInsets.only(
          top: _pressed ? 2 : 0,
          left: _pressed ? 2 : 0,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: NeoBrutalismTheme.white,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
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
