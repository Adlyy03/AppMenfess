import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';
import 'content_moderation_screen.dart';
import 'user_management_screen.dart';
import 'reports_management_screen.dart';
import 'audit_logs_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN DASHBOARD SCREEN — Neo-Brutalism Style
// Comprehensive administrative interface with stats and quick actions
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  final AdminProvider adminProvider;
  final AppProvider appProvider;

  const AdminDashboardScreen({
    super.key,
    required this.adminProvider,
    required this.appProvider,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch stats on screen load
    widget.adminProvider.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Admin App Bar
            _AdminAppBar(
              onLogout: () async {
                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => _LogoutConfirmDialog(),
                );
                
                if (confirm == true && context.mounted) {
                  // Logout
                  await widget.appProvider.signOut();
                  // Navigation will be handled automatically by auth state change
                }
              },
            ),

            // Main Content
            Expanded(
              child: ListenableBuilder(
                listenable: widget.adminProvider,
                builder: (context, _) {
                  // Loading state
                  if (widget.adminProvider.isLoading &&
                      widget.adminProvider.stats == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: NeoBrutalismTheme.blue,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // Error state
                  if (widget.adminProvider.error != null &&
                      widget.adminProvider.stats == null) {
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
                              'Failed to load dashboard',
                              style: NeoBrutalismTheme.heading3(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.adminProvider.error ?? 'Unknown error',
                              style: NeoBrutalismTheme.bodySmall(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _buildRetryButton(),
                          ],
                        ),
                      ),
                    );
                  }

                  final stats = widget.adminProvider.stats;
                  if (stats == null) {
                    return const Center(
                      child: Text('No stats available'),
                    );
                  }

                  // Success state with stats
                  return RefreshIndicator(
                    onRefresh: () => widget.adminProvider.fetchStats(),
                    color: NeoBrutalismTheme.blue,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Section
                          _SectionHeader(title: 'OVERVIEW'),
                          const SizedBox(height: 12),
                          _StatsGrid(
                            stats: [
                              _StatData(
                                'Total Users',
                                stats.totalUsers,
                                Icons.people,
                                NeoBrutalismTheme.blue,
                              ),
                              _StatData(
                                'Active Today',
                                stats.activeUsersToday,
                                Icons.online_prediction,
                                NeoBrutalismTheme.green,
                              ),
                              _StatData(
                                'Total Posts',
                                stats.totalMenfess,
                                Icons.article,
                                NeoBrutalismTheme.yellow,
                              ),
                              _StatData(
                                'Pending Reports',
                                stats.pendingReports,
                                Icons.flag,
                                NeoBrutalismTheme.red,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Today's Activity Section
                          _SectionHeader(title: 'TODAY\'S ACTIVITY'),
                          const SizedBox(height: 12),
                          _StatsGrid(
                            stats: [
                              _StatData(
                                'New Users',
                                stats.usersToday,
                                Icons.person_add,
                                NeoBrutalismTheme.blue,
                              ),
                              _StatData(
                                'New Posts',
                                stats.menfessToday,
                                Icons.add_circle,
                                NeoBrutalismTheme.yellow,
                              ),
                              _StatData(
                                'Reactions',
                                stats.reactionsToday,
                                Icons.favorite,
                                NeoBrutalismTheme.red,
                              ),
                              _StatData(
                                'Comments',
                                stats.commentsToday,
                                Icons.comment,
                                NeoBrutalismTheme.purple,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Quick Actions Section
                          _SectionHeader(title: 'QUICK ACTIONS'),
                          const SizedBox(height: 12),
                          _QuickActionsSection(
                            onModerateContent: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContentModerationScreen(
                                    adminProvider: widget.adminProvider,
                                    appProvider: widget.appProvider,
                                  ),
                                ),
                              );
                            },
                            onViewReports: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportsManagementScreen(
                                    adminProvider: widget.adminProvider,
                                    appProvider: widget.appProvider,
                                  ),
                                ),
                              );
                            },
                            onManageUsers: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserManagementScreen(
                                    adminProvider: widget.adminProvider,
                                    appProvider: widget.appProvider,
                                  ),
                                ),
                              );
                            },
                            onViewLogs: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuditLogsScreen(
                                    adminProvider: widget.adminProvider,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () => widget.adminProvider.fetchStats(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.blue,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow()],
        ),
        child: Text(
          'RETRY',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN APP BAR COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _AdminAppBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _AdminAppBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          // Admin Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.black,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidthThin,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 24,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'ADMIN DASHBOARD',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          // Logout Button
          _BrutalIconButton(
            icon: Icons.logout,
            bgColor: NeoBrutalismTheme.red,
            iconColor: NeoBrutalismTheme.white,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.black,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidthThin,
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.yellow,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS GRID COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final List<_StatData> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatsCard(
          label: stat.label,
          value: stat.value,
          icon: stat.icon,
          color: stat.color,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class StatsCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: NeoBrutalismTheme.white,
                ),
              ),
            ],
          ),
          // Value and Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.5,
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
// QUICK ACTIONS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onModerateContent;
  final VoidCallback onViewReports;
  final VoidCallback onManageUsers;
  final VoidCallback onViewLogs;

  const _QuickActionsSection({
    required this.onModerateContent,
    required this.onViewReports,
    required this.onManageUsers,
    required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionButton(
          label: 'MODERATE CONTENT',
          icon: Icons.content_paste,
          color: NeoBrutalismTheme.purple,
          onTap: onModerateContent,
        ),
        const SizedBox(height: 12),
        _QuickActionButton(
          label: 'VIEW REPORTS',
          icon: Icons.flag,
          color: NeoBrutalismTheme.red,
          onTap: onViewReports,
        ),
        const SizedBox(height: 12),
        _QuickActionButton(
          label: 'MANAGE USERS',
          icon: Icons.people,
          color: NeoBrutalismTheme.blue,
          onTap: onManageUsers,
        ),
        const SizedBox(height: 12),
        _QuickActionButton(
          label: 'VIEW AUDIT LOGS',
          icon: Icons.history,
          color: NeoBrutalismTheme.purple,
          onTap: onViewLogs,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: NeoBrutalismTheme.white,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.white,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward,
              size: 20,
              color: NeoBrutalismTheme.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRUTAL ICON BUTTON (Reusable)
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

// ─────────────────────────────────────────────────────────────────────────────
// STAT DATA MODEL (Internal)
// ─────────────────────────────────────────────────────────────────────────────

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  _StatData(this.label, this.value, this.icon, this.color);
}


// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT CONFIRMATION DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

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
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.red,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidthThin,
                ),
              ),
              child: const Icon(
                Icons.logout,
                size: 32,
                color: NeoBrutalismTheme.white,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'LOGOUT ADMIN?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              'Kamu akan keluar dari akun admin dan kembali ke halaman login.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: _DialogButton(
                    label: 'BATAL',
                    bgColor: NeoBrutalismTheme.white,
                    textColor: NeoBrutalismTheme.black,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm Button
                Expanded(
                  child: _DialogButton(
                    label: 'LOGOUT',
                    bgColor: NeoBrutalismTheme.red,
                    textColor: NeoBrutalismTheme.white,
                    onTap: () => Navigator.pop(context, true),
                  ),
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
// DIALOG BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.bgColor,
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
        height: 48,
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
          child: Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: widget.textColor,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
