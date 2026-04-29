import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'config/supabase_config.dart';
import 'core/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_navigation.dart';
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
  late StreamSubscription<AuthState> _authSubscription;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _provider = AppProvider();
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
    final userId = _provider.userId;

    // Clean OAuth ?code= param from URL on web — guarded so mobile doesn't crash
    _cleanOAuthUrl();

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final userId = _provider.userId;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Menfess Sekolah',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: _showSplash
              ? const SplashScreen()
              : (userId != null
                  ? MainNavigation(provider: _provider)
                  : AuthScreen(provider: _provider)),
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
