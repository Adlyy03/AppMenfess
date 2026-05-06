import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/report_model.dart';
import '../../widgets/admin/report_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORTS MANAGEMENT SCREEN — Neo-Brutalism Style
// Admin interface for managing user-submitted reports
// ─────────────────────────────────────────────────────────────────────────────

class ReportsManagementScreen extends StatefulWidget {
  final AdminProvider adminProvider;
  final AppProvider appProvider;

  const ReportsManagementScreen({
    super.key,
    required this.adminProvider,
    required this.appProvider,
  });

  @override
  State<ReportsManagementScreen> createState() =>
      _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    // Fetch reports on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.adminProvider.fetchReports();
    });
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _statusFilter = status;
    });
    widget.adminProvider.fetchReports(status: status);
  }

  Future<void> _handleResolveReport(ReportModel report) async {
    final resolutionNote = await _showResolutionDialog();
    if (resolutionNote == null || resolutionNote.trim().isEmpty) return;

    // Show loading
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

    final success = await widget.adminProvider.resolveReport(
      report.id,
      resolutionNote,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report resolved successfully',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.adminProvider.error ?? 'Failed to resolve report',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.red,
        ),
      );
    }
  }

  Future<void> _handleDismissReport(ReportModel report) async {
    final confirmed = await _showDismissConfirmation();
    if (confirmed != true) return;

    // Show loading
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

    final success = await widget.adminProvider.dismissReport(report.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report dismissed',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.yellow,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.adminProvider.error ?? 'Failed to dismiss report',
            style: NeoBrutalismTheme.bodyBold(),
          ),
          backgroundColor: NeoBrutalismTheme.red,
        ),
      );
    }
  }

  Future<String?> _showResolutionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => _BrutalInputDialog(
        title: 'RESOLVE REPORT',
        message: 'Masukkan catatan resolusi untuk laporan ini',
        hint: 'Contoh: Konten telah dihapus',
        controller: controller,
        confirmLabel: 'RESOLVE',
        confirmColor: NeoBrutalismTheme.green,
      ),
    );
  }

  Future<bool?> _showDismissConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => _BrutalConfirmDialog(
        title: 'DISMISS REPORT?',
        message: 'Laporan ini akan ditandai sebagai dismissed. Yakin?',
        confirmLabel: 'DISMISS',
        confirmColor: NeoBrutalismTheme.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _ReportsAppBar(
              onBack: () => Navigator.pop(context),
            ),

            // Filter Bar
            _FilterBar(
              currentFilter: _statusFilter,
              onFilterChanged: _onStatusFilterChanged,
            ),

            // Main Content
            Expanded(
              child: ListenableBuilder(
                listenable: widget.adminProvider,
                builder: (context, _) {
                  // Loading state
                  if (widget.adminProvider.isLoading &&
                      widget.adminProvider.reports.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: NeoBrutalismTheme.blue,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  // Error state
                  if (widget.adminProvider.error != null &&
                      widget.adminProvider.reports.isEmpty) {
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
                              'Failed to load reports',
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

                  final reports = widget.adminProvider.reports;

                  // Empty state
                  if (reports.isEmpty) {
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
                                color: NeoBrutalismTheme.yellow,
                                border: Border.all(
                                  color: NeoBrutalismTheme.black,
                                  width: NeoBrutalismTheme.borderWidth,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                size: 40,
                                color: NeoBrutalismTheme.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Reports',
                              style: NeoBrutalismTheme.heading3(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusFilter == null
                                  ? 'Tidak ada laporan saat ini'
                                  : 'Tidak ada laporan dengan status $_statusFilter',
                              style: NeoBrutalismTheme.bodySmall(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Reports list
                  return RefreshIndicator(
                    onRefresh: () =>
                        widget.adminProvider.fetchReports(status: _statusFilter),
                    color: NeoBrutalismTheme.blue,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ReportCard(
                            report: report,
                            onResolve: () => _handleResolveReport(report),
                            onDismiss: () => _handleDismissReport(report),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// REPORTS APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ReportsAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _ReportsAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
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
            iconColor: NeoBrutalismTheme.black,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'REPORTS',
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
              label: 'PENDING',
              isActive: currentFilter == 'pending',
              color: NeoBrutalismTheme.yellow,
              onTap: () => onFilterChanged('pending'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'REVIEWING',
              isActive: currentFilter == 'reviewing',
              color: NeoBrutalismTheme.blue,
              onTap: () => onFilterChanged('reviewing'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'RESOLVED',
              isActive: currentFilter == 'resolved',
              color: NeoBrutalismTheme.green,
              onTap: () => onFilterChanged('resolved'),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'DISMISSED',
              isActive: currentFilter == 'dismissed',
              color: NeoBrutalismTheme.purple,
              onTap: () => onFilterChanged('dismissed'),
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
            color: NeoBrutalismTheme.black,
            letterSpacing: 0.5,
          ),
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// BRUTAL CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _BrutalConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _BrutalConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
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
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'BATAL',
                    bgColor: NeoBrutalismTheme.white,
                    textColor: NeoBrutalismTheme.black,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    bgColor: confirmColor,
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
// BRUTAL INPUT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _BrutalInputDialog extends StatelessWidget {
  final String title;
  final String message;
  final String hint;
  final TextEditingController controller;
  final String confirmLabel;
  final Color confirmColor;

  const _BrutalInputDialog({
    required this.title,
    required this.message,
    required this.hint,
    required this.controller,
    required this.confirmLabel,
    required this.confirmColor,
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
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: NeoBrutalismTheme.inputDecoration(hint: hint),
              style: NeoBrutalismTheme.body(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'BATAL',
                    bgColor: NeoBrutalismTheme.white,
                    textColor: NeoBrutalismTheme.black,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    bgColor: confirmColor,
                    textColor: NeoBrutalismTheme.white,
                    onTap: () => Navigator.pop(context, controller.text),
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
// DIALOG BUTTON
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
