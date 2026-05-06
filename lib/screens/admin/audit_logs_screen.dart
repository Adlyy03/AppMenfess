import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_log_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUDIT LOGS SCREEN — Neo-Brutalism Style
// Admin interface for viewing audit logs of all admin actions
// ─────────────────────────────────────────────────────────────────────────────

class AuditLogsScreen extends StatefulWidget {
  final AdminProvider adminProvider;

  const AuditLogsScreen({
    super.key,
    required this.adminProvider,
  });

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String? _actionFilter;

  @override
  void initState() {
    super.initState();
    // Fetch logs on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.adminProvider.fetchLogs();
    });
  }

  void _onActionFilterChanged(String? action) {
    setState(() {
      _actionFilter = action;
    });
    widget.adminProvider.fetchLogs(actionFilter: action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _AuditLogsAppBar(
              onBack: () => Navigator.pop(context),
            ),

            // Filter Bar
            _FilterBar(
              currentFilter: _actionFilter,
              onFilterChanged: _onActionFilterChanged,
            ),

            // Main Content
            Expanded(
              child: ListenableBuilder(
                listenable: widget.adminProvider,
                builder: (context, _) {
                  // Loading state
                  if (widget.adminProvider.isLoading &&
                      widget.adminProvider.logs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: NeoBrutalismTheme.blue,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // Error state
                  if (widget.adminProvider.error != null &&
                      widget.adminProvider.logs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: NeoBrutalismTheme.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load logs',
                              style: NeoBrutalismTheme.heading3(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.adminProvider.error ?? 'Unknown error',
                              style: NeoBrutalismTheme.bodySmall(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final logs = widget.adminProvider.logs;

                  // Empty state
                  if (logs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: NeoBrutalismTheme.purple,
                                border: Border.all(
                                  color: NeoBrutalismTheme.black,
                                  width: NeoBrutalismTheme.borderWidth,
                                ),
                              ),
                              child: const Icon(
                                Icons.history,
                                size: 40,
                                color: NeoBrutalismTheme.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Logs',
                              style: NeoBrutalismTheme.heading3(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _actionFilter == null
                                  ? 'Belum ada aktivitas admin'
                                  : 'Tidak ada log untuk aksi $_actionFilter',
                              style: NeoBrutalismTheme.bodySmall(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Logs list
                  return RefreshIndicator(
                    onRefresh: () =>
                        widget.adminProvider.fetchLogs(actionFilter: _actionFilter),
                    color: NeoBrutalismTheme.blue,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AuditLogCard(log: log),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIT LOGS APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _AuditLogsAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _AuditLogsAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.purple,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          _BrutalIconButton(
            icon: Icons.arrow_back,
            bgColor: NeoBrutalismTheme.white,
            iconColor: NeoBrutalismTheme.black,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'AUDIT LOGS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.white,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String? currentFilter;
  final Function(String?) onFilterChanged;

  const _FilterBar({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterButton(
              label: 'ALL',
              isActive: currentFilter == null,
              onTap: () => onFilterChanged(null),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'DELETE POST',
              isActive: currentFilter == 'delete_menfess',
              color: NeoBrutalismTheme.red,
              onTap: () => onFilterChanged('delete_menfess'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'BAN USER',
              isActive: currentFilter == 'ban_user',
              color: NeoBrutalismTheme.orange,
              onTap: () => onFilterChanged('ban_user'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'UNBAN USER',
              isActive: currentFilter == 'unban_user',
              color: NeoBrutalismTheme.green,
              onTap: () => onFilterChanged('unban_user'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'CHANGE ROLE',
              isActive: currentFilter == 'change_role',
              color: NeoBrutalismTheme.blue,
              onTap: () => onFilterChanged('change_role'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'RESOLVE REPORT',
              isActive: currentFilter == 'resolve_report',
              color: NeoBrutalismTheme.purple,
              onTap: () => onFilterChanged('resolve_report'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    this.color = NeoBrutalismTheme.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: isActive ? [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isActive && color != NeoBrutalismTheme.white
                ? NeoBrutalismTheme.white
                : NeoBrutalismTheme.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIT LOG CARD
// ─────────────────────────────────────────────────────────────────────────────

class AuditLogCard extends StatelessWidget {
  final AdminLogModel log;

  const AuditLogCard({
    super.key,
    required this.log,
  });

  Color _getActionColor(String action) {
    switch (action) {
      case 'delete_menfess':
      case 'delete_comment':
        return NeoBrutalismTheme.red;
      case 'ban_user':
        return NeoBrutalismTheme.orange;
      case 'unban_user':
        return NeoBrutalismTheme.green;
      case 'change_role':
        return NeoBrutalismTheme.blue;
      case 'resolve_report':
      case 'dismiss_report':
        return NeoBrutalismTheme.purple;
      default:
        return NeoBrutalismTheme.yellow;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'delete_menfess':
      case 'delete_comment':
        return Icons.delete;
      case 'ban_user':
        return Icons.block;
      case 'unban_user':
        return Icons.check_circle;
      case 'change_role':
        return Icons.admin_panel_settings;
      case 'resolve_report':
        return Icons.check;
      case 'dismiss_report':
        return Icons.close;
      default:
        return Icons.info;
    }
  }

  String _formatAction(String action) {
    return action
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTargetType(String targetType) {
    return targetType[0].toUpperCase() + targetType.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor(log.action);
    final actionIcon = _getActionIcon(log.action);

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
          // Header: Action badge + timestamp
          Row(
            children: [
              // Action Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: actionColor,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      actionIcon,
                      size: 16,
                      color: NeoBrutalismTheme.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatAction(log.action),
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
              const Spacer(),
              // Timestamp
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(log.createdAt),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Admin info
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: NeoBrutalismTheme.black,
              ),
              const SizedBox(width: 6),
              Text(
                'Admin: ',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NeoBrutalismTheme.black,
                ),
              ),
              Text(
                log.adminDisplayName ?? 'Unknown',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Target info
          Row(
            children: [
              const Icon(
                Icons.gps_fixed,
                size: 16,
                color: NeoBrutalismTheme.black,
              ),
              const SizedBox(width: 6),
              Text(
                'Target: ',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NeoBrutalismTheme.black,
                ),
              ),
              Text(
                '${_formatTargetType(log.targetType)} (${log.targetId.substring(0, 8)}...)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black,
                ),
              ),
            ],
          ),

          // Details (if available)
          if (log.details != null && log.details!.isNotEmpty) ...[
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
                    'DETAILS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...log.details!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeoBrutalismTheme.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: NeoBrutalismTheme.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          // IP Address (if available)
          if (log.ipAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.computer,
                  size: 14,
                  color: NeoBrutalismTheme.black,
                ),
                const SizedBox(width: 6),
                Text(
                  'IP: ${log.ipAddress}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.black.withOpacity(0.6),
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
// BRUTAL ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _BrutalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color bgColor;
  final Color iconColor;

  const _BrutalIconButton({
    required this.icon,
    this.onTap,
    this.bgColor = NeoBrutalismTheme.white,
    this.iconColor = NeoBrutalismTheme.black,
  });

  @override
  State<_BrutalIconButton> createState() => _BrutalIconButtonState();
}

class _BrutalIconButtonState extends State<_BrutalIconButton> {
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
        width: 44,
        height: 44,
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.bgColor,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
