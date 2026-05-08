import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'config/supabase_config.dart';
import 'core/neo_brutalism_theme.dart';
import 'providers/app_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/update_provider.dart';
import 'screens/user/main_navigation.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';

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
  late final UpdateProvider _updateProvider;
  late StreamSubscription<AuthState> _authSubscription;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _provider = AppProvider();
    _adminProvider = AdminProvider();
    _updateProvider = UpdateProvider();
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
    
    // Auto-check for updates after app initialization
    _updateProvider.autoCheckForUpdates();
    
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
      listenable: Listenable.merge([_provider, _adminProvider, _updateProvider]),
      builder: (context, _) {
        final userId = _provider.userId;
        
        // Determine home screen based on authentication status
        Widget homeScreen;
        if (userId != null) {
          // All authenticated users go to Main Navigation (user home)
          // Admin access is handled through the admin tab in bottom navigation
          homeScreen = MainNavigation(
            provider: _provider,
            adminProvider: _adminProvider,
            updateProvider: _updateProvider,
          );
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
