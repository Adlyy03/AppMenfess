import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/app_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/update_provider.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../widgets/user/bottom_nav.dart';
import '../../widgets/update/update_banner.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'profile_screen.dart';
import 'bookmark_screen.dart';
import 'notification_screen.dart';
import '../admin/admin_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAIN NAVIGATION — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class MainNavigation extends StatefulWidget {
  final AppProvider provider;
  final AdminProvider adminProvider;
  final UpdateProvider updateProvider;
  
  const MainNavigation({
    super.key,
    required this.provider,
    required this.adminProvider,
    required this.updateProvider,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  // Per-tab animation controllers
  late final List<AnimationController> _tabCtrls;
  late final List<Animation<double>> _tabFades;
  late final List<Animation<Offset>> _tabSlides;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(provider: widget.provider),
      BookmarkScreen(provider: widget.provider),
      CreateScreen(provider: widget.provider),
      NotificationScreen(provider: widget.provider),
      ProfileScreen(provider: widget.provider),
    ];

    _tabCtrls = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: i == 0 ? 1.0 : 0.0,
      ),
    );

    _tabFades = _tabCtrls
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeIn),
            ))
        .toList();

    _tabSlides = _tabCtrls
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _tabCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();

    _tabCtrls[_currentIndex].reverse();
    setState(() {
      _currentIndex = index;
    });
    _tabCtrls[index].forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: Stack(
        children: [
          // Tab screens
          ...List.generate(
            _screens.length,
            (i) => FadeTransition(
              opacity: _tabFades[i],
              child: SlideTransition(
                position: _tabSlides[i],
                child: IgnorePointer(
                  ignoring: i != _currentIndex,
                  child: _screens[i],
                ),
              ),
            ),
          ),
          
          // Update Banner (shows at top if update available)
          ListenableBuilder(
            listenable: widget.updateProvider,
            builder: (context, _) {
              if (!widget.updateProvider.hasUpdateAvailable) {
                return const SizedBox.shrink();
              }
              
              return Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: UpdateBanner(
                  versionInfo: widget.updateProvider.availableUpdate!,
                  onUpdateComplete: () {
                    widget.updateProvider.dismissUpdate();
                  },
                ),
              );
            },
          ),
          
          // Admin Access Button (Floating)
          ListenableBuilder(
            listenable: widget.adminProvider,
            builder: (context, _) {
              if (!widget.adminProvider.isAdmin) return const SizedBox.shrink();
              
              return Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: _AdminAccessButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminDashboardScreen(
                          adminProvider: widget.adminProvider,
                          appProvider: widget.provider,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.provider,
        builder: (context, _) => BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          notificationBadgeCount: widget.provider.unreadNotificationCount,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN ACCESS BUTTON — Floating Button for Admins
// ─────────────────────────────────────────────────────────────────────────────

class _AdminAccessButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AdminAccessButton({required this.onTap});

  @override
  State<_AdminAccessButton> createState() => _AdminAccessButtonState();
}

class _AdminAccessButtonState extends State<_AdminAccessButton> {
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
        width: 56,
        height: 56,
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.purple,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 4, offsetY: 4)],
        ),
        child: const Icon(
          Icons.admin_panel_settings,
          size: 28,
          color: NeoBrutalismTheme.white,
        ),
      ),
    );
  }
}
