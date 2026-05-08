import 'package:flutter/material.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/app_version_model.dart';
import '../../services/app_update_service.dart';

/// Dialog for app update notification and download
class AppUpdateDialog extends StatefulWidget {
  final AppVersionModel versionInfo;
  final VoidCallback? onUpdateComplete;
  final VoidCallback? onUpdateSkipped;

  const AppUpdateDialog({
    super.key,
    required this.versionInfo,
    this.onUpdateComplete,
    this.onUpdateSkipped,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog>
    with TickerProviderStateMixin {
  final AppUpdateService _updateService = AppUpdateService();
  
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = '';
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Memulai download...';
      _downloadProgress = 0.0;
    });

    _progressController.forward();

    final success = await _updateService.downloadAndInstallApk(
      downloadUrl: widget.versionInfo.url,
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
          _statusMessage = 'Downloading... ${(progress * 100).toStringAsFixed(1)}%';
        });
      },
      onDownloadComplete: () {
        setState(() {
          _statusMessage = 'Download selesai! Membuka installer...';
        });
      },
    );

    if (success) {
      widget.onUpdateComplete?.call();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Gagal mengupdate. Silakan coba lagi.';
      });
      _progressController.reverse();
    }
  }

  void _skipUpdate() {
    widget.onUpdateSkipped?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [
            NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.green,
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: NeoBrutalismTheme.borderWidth,
                    ),
                  ),
                  child: const Icon(
                    Icons.system_update,
                    color: NeoBrutalismTheme.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPDATE TERSEDIA',
                        style: NeoBrutalismTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.black,
                        ),
                      ),
                      Text(
                        'Versi ${widget.versionInfo.version}',
                        style: NeoBrutalismTheme.textTheme.bodyMedium?.copyWith(
                          color: NeoBrutalismTheme.gray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            if (widget.versionInfo.description != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.lightGray,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidth,
                  ),
                ),
                child: Text(
                  widget.versionInfo.description!,
                  style: NeoBrutalismTheme.textTheme.bodyMedium?.copyWith(
                    color: NeoBrutalismTheme.black,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Progress Section
            if (_isDownloading) ...[
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress Bar
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: NeoBrutalismTheme.lightGray,
                          border: Border.all(
                            color: NeoBrutalismTheme.black,
                            width: NeoBrutalismTheme.borderWidth,
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _downloadProgress,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: NeoBrutalismTheme.green,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Status Message
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: NeoBrutalismTheme.textTheme.bodyMedium?.copyWith(
                          color: NeoBrutalismTheme.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (!_isDownloading) ...[
              Row(
                children: [
                  // Skip Button (if not force update)
                  if (!widget.versionInfo.forceUpdate) ...[
                    Expanded(
                      child: _UpdateButton(
                        label: 'NANTI SAJA',
                        color: NeoBrutalismTheme.gray,
                        onTap: _skipUpdate,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // Update Button
                  Expanded(
                    flex: widget.versionInfo.forceUpdate ? 1 : 1,
                    child: _UpdateButton(
                      label: 'UPDATE SEKARANG',
                      color: NeoBrutalismTheme.green,
                      onTap: _startUpdate,
                    ),
                  ),
                ],
              ),
            ],

            // Force Update Message
            if (widget.versionInfo.forceUpdate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.red,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: NeoBrutalismTheme.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Update wajib untuk melanjutkan',
                        style: NeoBrutalismTheme.textTheme.bodySmall?.copyWith(
                          color: NeoBrutalismTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom button for update dialog
class _UpdateButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UpdateButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<_UpdateButton> {
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
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 4, offsetY: 4)],
        ),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: NeoBrutalismTheme.textTheme.labelLarge?.copyWith(
            color: NeoBrutalismTheme.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}