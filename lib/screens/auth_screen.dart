import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../core/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final AppProvider provider;
  const AuthScreen({super.key, required this.provider});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await widget.provider.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await widget.provider.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _displayNameController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('email_not_confirmed')) {
          msg = 'Email kamu belum dikonfirmasi. Cek kotak masuk/spam email kamu atau matikan "Confirm Email" di dashboard Supabase.';
        } else if (msg.contains('invalid_credentials')) {
          msg = 'Email atau kata sandi salah.';
        } else if (msg.contains('rate limit exceeded')) {
          msg = 'Terlalu banyak mencoba. Tunggu beberapa menit lagi ya.';
        }
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 450 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo & Title ──────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.message_rounded, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isLogin ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin 
                        ? 'Masuk untuk lanjut berbagi menfess anonim' 
                        : 'Daftar sekarang untuk mulai mengirim menfess',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Auth Form ─────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              hintText: 'Nama Tampilan (e.g. Anon#123)',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v != null && v.length >= 3 ? null : 'Nama minimal 3 karakter',
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Alamat Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v != null && v.contains('@') ? null : 'Email tidak valid',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            hintText: 'Kata Sandi',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) => v != null && v.length >= 6 ? null : 'Sandi minimal 6 karakter',
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _error!,
                              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isLogin ? 'Masuk' : 'Daftar Sekarang'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Toggle Login/Register ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _isLogin = !_isLogin;
                          _error = null;
                        }),
                        child: Text(_isLogin ? 'Daftar' : 'Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
