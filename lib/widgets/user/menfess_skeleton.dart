import 'package:flutter/material.dart';
import '../../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MENFESS SKELETON — Neo-Brutalism Loading Placeholder
// ─────────────────────────────────────────────────────────────────────────────
class MenfessSkeleton extends StatefulWidget {
  const MenfessSkeleton({super.key});

  @override
  State<MenfessSkeleton> createState() => _MenfessSkeletonState();
}

class _MenfessSkeletonState extends State<MenfessSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _shimmer = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, a) {
          final opacity = _shimmer.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _Bone(width: 44, height: 44, opacity: opacity),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bone(width: 120, height: 14, opacity: opacity),
                      const SizedBox(height: 6),
                      _Bone(width: 80, height: 12, opacity: opacity),
                    ],
                  ),
                  const Spacer(),
                  _Bone(width: 50, height: 24, opacity: opacity),
                ],
              ),
              const SizedBox(height: 16),
              // Content lines
              _Bone(width: double.infinity, height: 14, opacity: opacity),
              const SizedBox(height: 8),
              _Bone(width: double.infinity, height: 14, opacity: opacity),
              const SizedBox(height: 8),
              _Bone(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                opacity: opacity,
              ),
              const SizedBox(height: 16),
              // View count
              _Bone(width: 100, height: 12, opacity: opacity),
              const SizedBox(height: 14),
              // Divider
              Container(
                height: 3,
                color: NeoBrutalismTheme.black.withOpacity(0.1),
              ),
              const SizedBox(height: 14),
              // Actions
              Row(
                children: [
                  _Bone(width: 60, height: 32, opacity: opacity),
                  const SizedBox(width: 12),
                  _Bone(width: 60, height: 32, opacity: opacity),
                  const SizedBox(width: 12),
                  _Bone(width: 40, height: 32, opacity: opacity),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _Bone({
    required this.width,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.black.withOpacity(opacity * 0.15),
        border: Border.all(
          color: NeoBrutalismTheme.black.withOpacity(opacity * 0.2),
          width: 2,
        ),
      ),
    );
  }
}
