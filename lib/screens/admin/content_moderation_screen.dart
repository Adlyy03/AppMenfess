import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/menfess_model.dart';
import '../../widgets/admin/menfess_admin_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT MODERATION SCREEN — Neo-Brutalism Style
// Admin interface for managing and moderating menfess posts
// ─────────────────────────────────────────────────────────────────────────────

class ContentModerationScreen extends StatefulWidget {
  final AdminProvider adminProvider;
  final AppProvider appProvider;

  const ContentModerationScreen({
    super.key,
    required this.adminProvider,
    required this.appProvider,
  });

  @override
  State<ContentModerationScreen> createState() =>
      _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> {
  String _filterMode = 'all'; // 'all', 'reported', 'recent'
  bool _bulkSelectionMode = false;
  final Set<String> _selectedMenfessIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch menfess posts after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appProvider.fetchMenfess();
    });
  }

  void _toggleBulkSelection() {
    setState(() {
      _bulkSelectionMode = !_bulkSelectionMode;
      if (!_bulkSelectionMode) {
        _selectedMenfessIds.clear();
      }
    });
  }

  void _toggleMenfessSelection(String menfessId) {
    setState(() {
      if (_selectedMenfessIds.contains(menfessId)) {
        _selectedMenfessIds.remove(menfessId);
      } else {
        _selectedMenfessIds.add(menfessId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      final filteredList = _getFilteredMenfessList();
      _selectedMenfessIds.addAll(filteredList.map((m) => m.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMenfessIds.clear();
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedMenfessIds.isEmpty) return;

    final confirmed = await _showBulkDeleteConfirmation();
    if (confirmed != true) return;

    final reason = await _showReasonDialog('Bulk Delete');
    if (reason == null || reason.trim().isEmpty) return;

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: NeoBrutalismTheme.blue,
          strokeWidth: 3,
        ),
      ),
    );

    int successCount = 0;
    int failCount = 0;

    // Process each deletion individually
    for (final menfessId in _selectedMenfessIds) {
      final success = await widget.adminProvider.deleteMenfess(
        menfessId,
        reason,
      );
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    // Close loading dialog
    if (!mounted) return;
    Navigator.pop(context);

    // Clear selection
    setState(() {
      _selectedMenfessIds.clear();
      _bulkSelectionMode = false;
    });

    // Refresh list
    await widget.appProvider.fetchMenfess();

    // Show result
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted: $successCount, Failed: $failCount',
          style: NeoBrutalismTheme.bodyBold(),
        ),
        backgroundColor: successCount > 0
            ? NeoBrutalismTheme.green
            : NeoBrutalismTheme.red,
      ),
    );
  }

  Future<bool?> _showBulkDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => _BrutalConfirmDialog(
        title: 'BULK DELETE',
        message:
            'Are you sure you want to delete ${_selectedMenfessIds.length} menfess posts? This action cannot be undone.',
        confirmText: 'DELETE ALL',
        confirmColor: NeoBrutalismTheme.red,
        cancelText: 'CANCEL',
      ),
    );
  }

  Future<String?> _showReasonDialog(String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => _BrutalInputDialog(
        title: title,
        message: 'Please provide a reason for this action:',
        controller: controller,
        confirmText: 'CONFIRM',
        cancelText: 'CANCEL',
      ),
    );
  }

  List<MenfessModel> _getFilteredMenfessList() {
    final allMenfess = widget.appProvider.menfessList;

    switch (_filterMode) {
      case 'reported':
        // TODO: Filter by reported posts when report data is available
        return allMenfess;
      case 'recent':
        // Already sorted by recent in the provider
        return allMenfess;
      case 'all':
      default:
        return allMenfess;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Filter Bar
            _buildFilterBar(),

            // Bulk Actions Bar (shown when in bulk selection mode)
            if (_bulkSelectionMode) _buildBulkActionsBar(),

            // Content List
            Expanded(
              child: ListenableBuilder(
                listenable: widget.appProvider,
                builder: (context, _) {
                  // Loading state
                  if (widget.appProvider.isLoading &&
                      widget.appProvider.menfessList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: NeoBrutalismTheme.blue,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // Error state
                  if (widget.appProvider.error != null &&
                      widget.appProvider.menfessList.isEmpty) {
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
                              'Failed to load posts',
                              style: NeoBrutalismTheme.heading3(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.appProvider.error ?? 'Unknown error',
                              style: NeoBrutalismTheme.bodySmall(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredList = _getFilteredMenfessList();

                  // Empty state
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 64,
                              color: NeoBrutalismTheme.black,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts found',
                              style: NeoBrutalismTheme.heading3(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success state with posts
                  return RefreshIndicator(
                    onRefresh: () => widget.appProvider.fetchMenfess(),
                    color: NeoBrutalismTheme.blue,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final menfess = filteredList[index];
                        final isSelected =
                            _selectedMenfessIds.contains(menfess.id);

                        return MenfessAdminCard(
                          menfess: menfess,
                          adminProvider: widget.adminProvider,
                          appProvider: widget.appProvider,
                          bulkSelectionMode: _bulkSelectionMode,
                          isSelected: isSelected,
                          onSelectionToggle: () =>
                              _toggleMenfessSelection(menfess.id),
                          onDeleted: () => widget.appProvider.fetchMenfess(),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.red,
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
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              'CONTENT MODERATION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Bulk Selection Toggle
          _BrutalIconButton(
            icon: _bulkSelectionMode
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            bgColor: _bulkSelectionMode
                ? NeoBrutalismTheme.yellow
                : NeoBrutalismTheme.white,
            onTap: _toggleBulkSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
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
      child: Row(
        children: [
          _FilterButton(
            label: 'ALL',
            isActive: _filterMode == 'all',
            onTap: () => setState(() => _filterMode = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: 'REPORTED',
            isActive: _filterMode == 'reported',
            onTap: () => setState(() => _filterMode = 'reported'),
          ),
          const SizedBox(width: 8),
          _FilterButton(
            label: 'RECENT',
            isActive: _filterMode == 'recent',
            onTap: () => setState(() => _filterMode = 'recent'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedMenfessIds.length} SELECTED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          _BulkActionButton(
            label: 'SELECT ALL',
            icon: Icons.select_all,
            onTap: _selectAll,
          ),
          const SizedBox(width: 8),
          _BulkActionButton(
            label: 'CLEAR',
            icon: Icons.clear,
            onTap: _clearSelection,
          ),
          const Spacer(),
          _BulkActionButton(
            label: 'DELETE',
            icon: Icons.delete,
            color: NeoBrutalismTheme.red,
            onTap: _bulkDelete,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _FilterButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
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
          12 + (_pressed ? 2 : 0),
          8 + (_pressed ? 2 : 0),
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: widget.isActive
              ? NeoBrutalismTheme.blue
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
            fontWeight: FontWeight.w900,
            color: widget.isActive
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
// BULK ACTION BUTTON COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _BulkActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BulkActionButton({
    required this.label,
    required this.icon,
    this.color = NeoBrutalismTheme.black,
    required this.onTap,
  });

  @override
  State<_BulkActionButton> createState() => _BulkActionButtonState();
}

class _BulkActionButtonState extends State<_BulkActionButton> {
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
          10 + (_pressed ? 2 : 0),
          6 + (_pressed ? 2 : 0),
          10,
          6,
        ),
        decoration: BoxDecoration(
          color: widget.color == NeoBrutalismTheme.red
              ? NeoBrutalismTheme.red
              : NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 16,
              color: widget.color == NeoBrutalismTheme.red
                  ? NeoBrutalismTheme.white
                  : widget.color,
            ),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: widget.color == NeoBrutalismTheme.red
                    ? NeoBrutalismTheme.white
                    : widget.color,
                letterSpacing: 0.5,
              ),
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
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
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
          boxShadow:
              _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
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
// BRUTAL CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _BrutalConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;

  const _BrutalConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor = NeoBrutalismTheme.red,
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
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: cancelText,
                  color: NeoBrutalismTheme.white,
                  textColor: NeoBrutalismTheme.black,
                  onTap: () => Navigator.pop(context, false),
                ),
                const SizedBox(width: 12),
                _DialogButton(
                  label: confirmText,
                  color: confirmColor,
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
// BRUTAL INPUT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _BrutalInputDialog extends StatelessWidget {
  final String title;
  final String message;
  final TextEditingController controller;
  final String confirmText;
  final String cancelText;

  const _BrutalInputDialog({
    required this.title,
    required this.message,
    required this.controller,
    required this.confirmText,
    required this.cancelText,
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
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: NeoBrutalismTheme.inputDecoration(
                hint: 'Enter reason...',
              ),
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: cancelText,
                  color: NeoBrutalismTheme.white,
                  textColor: NeoBrutalismTheme.black,
                  onTap: () => Navigator.pop(context, null),
                ),
                const SizedBox(width: 12),
                _DialogButton(
                  label: confirmText,
                  color: NeoBrutalismTheme.blue,
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
