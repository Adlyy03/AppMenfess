import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.yellow,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidth,
                ),
                boxShadow: [
                  NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8),
                ],
              ),
              child: const Icon(
                Icons.bolt,
                size: 64,
                color: NeoBrutalismTheme.black,
              ),
            ),

            const SizedBox(height: 32),

            // App name
            Text(
              'MENFESS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 2.0,
              ),
            ),

            const SizedBox(height: 12),

            // Tagline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.blue,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidthThin,
                ),
              ),
              child: Text(
                'BERBAGI PESAN ANONIM',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.2;
                    final opacity = ((_pulseCtrl.value - delay).clamp(0.0, 1.0) * 2)
                        .clamp(0.3, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: NeoBrutalismTheme.black.withOpacity(opacity),
                        border: Border.all(
                          color: NeoBrutalismTheme.black,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 16),

            Text(
              'MEMUAT...',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black.withOpacity(0.6),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) return;
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final status = await Permission.notification.request();
      debugPrint('🔔 Notification Permission Status: $status');
    } catch (e) {
      debugPrint('🔔 Skip notification permission: $e');
    }
  }
}
