import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'config/supabase_config.dart';
import 'core/neo_brutalism_theme.dart';
import 'providers/app_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/user/main_navigation.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MenfessApp());
}

class MenfessApp extends StatefulWidget {
  const MenfessApp({super.key});

  @override
  State<MenfessApp> createState() => _MenfessAppState();
}

class _MenfessAppState extends State<MenfessApp> {
  late final AppProvider _provider;
  late final AdminProvider _adminProvider;
  late StreamSubscription<AuthState> _authSubscription;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _provider = AppProvider();
    _adminProvider = AdminProvider();
    _setupAuthListener();
    _initApp();
  }

  void _setupAuthListener() {
    final supabase = Supabase.instance.client;
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        final event = data.event;
        debugPrint('🔐 Auth Event: $event');

        if (session != null && session.user.id.isNotEmpty) {
          debugPrint('✅ LOGIN: ${session.user.email}');
          _provider.setUserId(session.user.id);
          // Initialize admin provider for logged-in users
          _adminProvider.initialize();
        } else {
          debugPrint('❌ LOGOUT');
          _provider.setUserId(null);
        }
        if (mounted) setState(() {});
      },
      onError: (error) {
        debugPrint('⚠️ Auth Error: $error');
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _initApp() async {
    await _provider.init();
    // Beri jeda sedikit agar animasi splash terlihat cantik
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clean OAuth ?code= param from URL on web — guarded so mobile doesn't crash
    _cleanOAuthUrl();

    return ListenableBuilder(
      listenable: Listenable.merge([_provider, _adminProvider]),
      builder: (context, _) {
        final userId = _provider.userId;
        
        // Determine home screen based on user role
        Widget homeScreen;
        if (userId != null) {
          // Check if user is admin (super_admin or moderator)
          if (_adminProvider.isAdmin) {
            // Admin users go directly to Admin Dashboard
            homeScreen = AdminDashboardScreen(
              adminProvider: _adminProvider,
              appProvider: _provider,
            );
          } else {
            // Regular users go to Main Navigation
            homeScreen = MainNavigation(
              provider: _provider,
              adminProvider: _adminProvider,
            );
          }
        } else {
          // Not logged in, show auth screen
          homeScreen = AuthScreen(provider: _provider);
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Menfess Sekolah',
          theme: NeoBrutalismTheme.theme,
          themeMode: ThemeMode.light,
          home: _showSplash ? const SplashScreen() : homeScreen,
        );
      },
    );
  }

  void _cleanOAuthUrl() {
    // Only runs on web where Uri.base is meaningful
    try {
      if (Uri.base.hasQuery &&
          Uri.base.queryParameters.containsKey('code')) {
        // Use conditional import pattern via dart:js_interop equivalent
        // For web: window.history.replaceState is handled by Supabase itself in v2
        // Nothing to do — Supabase Flutter SDK cleans it automatically.
      }
    } catch (_) {}
  }
}
