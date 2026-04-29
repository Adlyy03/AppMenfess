import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final AppProvider provider;
  const MainNavigation({super.key, required this.provider});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(provider: widget.provider),
      CreateScreen(provider: widget.provider),
      const Center(child: Text('Hot (Coming Soon)')),
      ProfileScreen(provider: widget.provider),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(theme),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(theme),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
        labelType: NavigationRailLabelType.none,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
          ),
        ),
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.home_filled), label: Text('Home')),
          NavigationRailDestination(icon: Icon(Icons.add_box_rounded), label: Text('Create')),
          NavigationRailDestination(icon: Icon(Icons.whatshot_rounded), label: Text('Hot')),
          NavigationRailDestination(icon: Icon(Icons.person_rounded), label: Text('Profile')),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_filled), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded), label: 'Create'),
        NavigationDestination(icon: Icon(Icons.whatshot_outlined), selectedIcon: Icon(Icons.whatshot_rounded), label: 'Hot'),
        NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
