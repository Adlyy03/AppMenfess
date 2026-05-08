import 'package:flutter/material.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../models/app_version_model.dart';
import 'app_update_dialog.dart';

/// Banner widget to show update notification
class UpdateBanner extends StatefulWidget {
  final AppVersionModel versionInfo;
  final VoidCallback? onUpdateComplete;

  const UpdateBanner({
    super.key,
    required this.versionInfo,
    this.onUpdateComplete,
  });

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: !widget.versionInfo.forceUpdate,
      builder: (context) => AppUpdateDialog(
        versionInfo: widget.versionInfo,
        onUpdateComplete: () {
          widget.onUpdateComplete?.call();
          _animationController.reverse();
        },
        onUpdateSkipped: () {
          _animationController.reverse();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.green,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidth,
                ),
                boxShadow: [
                  NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showUpdateDialog,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Update Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NeoBrutalismTheme.white,
                            border: Border.all(
                              color: NeoBrutalismTheme.black,
                              width: NeoBrutalismTheme.borderWidth,
                            ),
                          ),
                          child: const Icon(
                            Icons.system_update,
                            color: NeoBrutalismTheme.green,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Update Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPDATE TERSEDIA!',
                                style: NeoBrutalismTheme.textTheme.titleMedium?.copyWith(
                                  color: NeoBrutalismTheme.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Versi ${widget.versionInfo.version} siap didownload',
                                style: NeoBrutalismTheme.textTheme.bodyMedium?.copyWith(
                                  color: NeoBrutalismTheme.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow Icon
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: NeoBrutalismTheme.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating update button (alternative to banner)
class UpdateFloatingButton extends StatefulWidget {
  final AppVersionModel versionInfo;
  final VoidCallback? onUpdateComplete;

  const UpdateFloatingButton({
    super.key,
    required this.versionInfo,
    this.onUpdateComplete,
  });

  @override
  State<UpdateFloatingButton> createState() => _UpdateFloatingButtonState();
}

class _UpdateFloatingButtonState extends State<UpdateFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _bounceController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: !widget.versionInfo.forceUpdate,
      builder: (context) => AppUpdateDialog(
        versionInfo: widget.versionInfo,
        onUpdateComplete: widget.onUpdateComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _bounceController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value * _pulseAnimation.value,
          child: GestureDetector(
            onTap: _showUpdateDialog,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.green,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidth,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  NeoBrutalismTheme.hardShadow(offsetX: 4, offsetY: 4),
                ],
              ),
              child: const Icon(
                Icons.system_update,
                color: NeoBrutalismTheme.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}