import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user_admin_model.dart';
import '../../models/user_role.dart';
import '../../widgets/admin/user_admin_card.dart';
import '../../widgets/admin/ban_user_dialog.dart';
import '../../widgets/admin/unban_user_dialog.dart';
import '../../widgets/admin/change_role_dialog.dart';
import '../../widgets/admin/delete_user_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USER MANAGEMENT SCREEN — Neo-Brutalism Style
// Comprehensive user management interface with search, filters, and bulk actions
// ─────────────────────────────────────────────────────────────────────────────

class UserManagementScreen extends StatefulWidget {
  final AdminProvider adminProvider;
  final AppProvider appProvider;

  const UserManagementScreen({
    super.key,
    required this.adminProvider,
    required this.appProvider,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  UserRole? _roleFilter;
  final Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // Fetch users after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.adminProvider.fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce search - wait for user to stop typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        widget.adminProvider.fetchUsers(
          searchQuery: query.isEmpty ? null : query,
          roleFilter: _roleFilter,
        );
      }
    });
  }

  void _onRoleFilterChanged(UserRole? role) {
    setState(() {
      _roleFilter = role;
    });
    widget.adminProvider.fetchUsers(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      roleFilter: role,
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUserIds.clear();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedUserIds.addAll(
        widget.adminProvider.users.map((u) => u.id),
      );
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUserIds.clear();
    });
  }

  Future<void> _bulkBanUsers() async {
    if (_selectedUserIds.isEmpty) return;

    final reason = await _showBulkBanReasonDialog();
    if (reason == null || reason.isEmpty) return;

    int successCount = 0;
    int failureCount = 0;

    for (final userId in _selectedUserIds) {
      final success = await widget.adminProvider.banUser(
        targetUserId: userId,
        reason: reason,
      );
      if (success) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bulk ban complete: $successCount succeeded, $failureCount failed',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: successCount > 0
              ? NeoBrutalismTheme.green
              : NeoBrutalismTheme.red,
        ),
      );

      setState(() {
        _selectedUserIds.clear();
        _isSelectionMode = false;
      });

      widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      );
    }
  }

  Future<String?> _showBulkBanReasonDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: NeoBrutalismTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          side: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
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
                'BULK BAN REASON',
                style: NeoBrutalismTheme.heading3(),
              ),
              const SizedBox(height: 16),
              Text(
                'Banning ${_selectedUserIds.length} users',
                style: NeoBrutalismTheme.body(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: NeoBrutalismTheme.inputDecoration(
                  hint: 'Enter ban reason...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogButton(
                    label: 'CANCEL',
                    color: NeoBrutalismTheme.white,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _DialogButton(
                    label: 'BAN ALL',
                    color: NeoBrutalismTheme.red,
                    onTap: () => Navigator.pop(context, controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _UserManagementAppBar(
              onBack: () => Navigator.pop(context),
              isSelectionMode: _isSelectionMode,
              selectedCount: _selectedUserIds.length,
              onToggleSelection: _toggleSelectionMode,
              onSelectAll: _selectAll,
              onClearSelection: _clearSelection,
              onBulkBan: _bulkBanUsers,
            ),

            // Search and Filter Bar
            _SearchAndFilterBar(
              searchController: _searchController,
              roleFilter: _roleFilter,
              onSearchChanged: _onSearchChanged,
              onRoleFilterChanged: _onRoleFilterChanged,
            ),

            // User List
            Expanded(
              child: ListenableBuilder(
                listenable: widget.adminProvider,
                builder: (context, _) {
                  // Loading state
                  if (widget.adminProvider.isLoading &&
                      widget.adminProvider.users.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: NeoBrutalismTheme.blue,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // Error state
                  if (widget.adminProvider.error != null &&
                      widget.adminProvider.users.isEmpty) {
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
                              'Failed to load users',
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

                  final users = widget.adminProvider.users;
                  if (users.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: NeoBrutalismTheme.black,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: NeoBrutalismTheme.heading3(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: NeoBrutalismTheme.bodySmall(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success state with users
                  return RefreshIndicator(
                    onRefresh: () => widget.adminProvider.fetchUsers(
                      searchQuery: _searchController.text.isEmpty
                          ? null
                          : _searchController.text,
                      roleFilter: _roleFilter,
                    ),
                    color: NeoBrutalismTheme.blue,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = _selectedUserIds.contains(user.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UserAdminCard(
                            user: user,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onTap: _isSelectionMode
                                ? () => _toggleUserSelection(user.id)
                                : null,
                            onBan: () => _showBanDialog(user),
                            onUnban: () => _showUnbanDialog(user),
                            onChangeRole: widget.adminProvider.isSuperAdmin
                                ? () => _showChangeRoleDialog(user)
                                : null,
                            onDelete: widget.adminProvider.isSuperAdmin
                                ? () => _showDeleteDialog(user)
                                : null,
                          ),
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

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () => widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      ),
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

  Future<void> _showBanDialog(UserAdminModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BanUserDialog(
        user: user,
        adminProvider: widget.adminProvider,
      ),
    );

    if (result == true && mounted) {
      widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      );
    }
  }

  Future<void> _showUnbanDialog(UserAdminModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UnbanUserDialog(
        user: user,
        adminProvider: widget.adminProvider,
      ),
    );

    if (result == true && mounted) {
      widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      );
    }
  }

  Future<void> _showChangeRoleDialog(UserAdminModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ChangeRoleDialog(
        user: user,
        adminProvider: widget.adminProvider,
      ),
    );

    if (result == true && mounted) {
      widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      );
    }
  }

  Future<void> _showDeleteDialog(UserAdminModel user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteUserDialog(
        user: user,
        adminProvider: widget.adminProvider,
      ),
    );

    if (result == true && mounted) {
      widget.adminProvider.fetchUsers(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        roleFilter: _roleFilter,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER MANAGEMENT APP BAR COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _UserManagementAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onToggleSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkBan;

  const _UserManagementAppBar({
    required this.onBack,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onToggleSelection,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onBulkBan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.blue,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: isSelectionMode
          ? _buildSelectionModeBar()
          : _buildNormalModeBar(),
    );
  }

  Widget _buildNormalModeBar() {
    return Row(
      children: [
        // Back Button
        _BrutalIconButton(
          icon: Icons.arrow_back,
          bgColor: NeoBrutalismTheme.white,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        // Title
        Text(
          'USER MANAGEMENT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.white,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        // Selection Mode Toggle
        _BrutalIconButton(
          icon: Icons.checklist,
          bgColor: NeoBrutalismTheme.white,
          onTap: onToggleSelection,
        ),
      ],
    );
  }

  Widget _buildSelectionModeBar() {
    return Row(
      children: [
        // Exit Selection Mode
        _BrutalIconButton(
          icon: Icons.close,
          bgColor: NeoBrutalismTheme.white,
          onTap: onToggleSelection,
        ),
        const SizedBox(width: 12),
        // Selected Count
        Text(
          '$selectedCount SELECTED',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.white,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        // Select All
        _BrutalIconButton(
          icon: Icons.select_all,
          bgColor: NeoBrutalismTheme.white,
          onTap: onSelectAll,
        ),
        const SizedBox(width: 8),
        // Clear Selection
        _BrutalIconButton(
          icon: Icons.clear_all,
          bgColor: NeoBrutalismTheme.white,
          onTap: onClearSelection,
        ),
        const SizedBox(width: 8),
        // Bulk Ban
        _BrutalIconButton(
          icon: Icons.block,
          bgColor: selectedCount > 0
              ? NeoBrutalismTheme.red
              : NeoBrutalismTheme.white,
          iconColor: selectedCount > 0
              ? NeoBrutalismTheme.white
              : NeoBrutalismTheme.black,
          onTap: selectedCount > 0 ? onBulkBan : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH AND FILTER BAR COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final UserRole? roleFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UserRole?> onRoleFilterChanged;

  const _SearchAndFilterBar({
    required this.searchController,
    required this.roleFilter,
    required this.onSearchChanged,
    required this.onRoleFilterChanged,
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
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: NeoBrutalismTheme.inputDecoration(
              hint: 'Search users by name...',
              icon: Icons.search,
            ),
          ),
          const SizedBox(height: 12),
          // Role Filter
          Row(
            children: [
              Text(
                'FILTER BY ROLE:',
                style: NeoBrutalismTheme.label(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'ALL',
                        isSelected: roleFilter == null,
                        onTap: () => onRoleFilterChanged(null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'USER',
                        isSelected: roleFilter == UserRole.user,
                        onTap: () => onRoleFilterChanged(UserRole.user),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'MODERATOR',
                        isSelected: roleFilter == UserRole.moderator,
                        onTap: () => onRoleFilterChanged(UserRole.moderator),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'SUPER ADMIN',
                        isSelected: roleFilter == UserRole.superAdmin,
                        onTap: () => onRoleFilterChanged(UserRole.superAdmin),
                      ),
                    ],
                  ),
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
// FILTER CHIP COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.only(
          top: _pressed ? 2 : 0,
          left: _pressed ? 2 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? NeoBrutalismTheme.yellow
              : NeoBrutalismTheme.white,
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
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: NeoBrutalismTheme.black,
            letterSpacing: 0.5,
          ),
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
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.onTap != null
                ? widget.iconColor
                : widget.iconColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG BUTTON (Reusable)
// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          boxShadow: _pressed
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
