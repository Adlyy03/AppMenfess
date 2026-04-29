import 'package:flutter/material.dart';

class MenfessSkeleton extends StatefulWidget {
  const MenfessSkeleton({super.key});

  @override
  State<MenfessSkeleton> createState() => _MenfessSkeletonState();
}

class _MenfessSkeletonState extends State<MenfessSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onSurface.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                FadeTransition(
                  opacity: _opacity,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _opacity,
                        child: Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _opacity,
                        child: Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content skeleton
            FadeTransition(
              opacity: _opacity,
              child: Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _opacity,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action row skeleton
            Row(
              children: [
                for (int i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 24),
                  FadeTransition(
                    opacity: _opacity,
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                FadeTransition(
                  opacity: _opacity,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
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
