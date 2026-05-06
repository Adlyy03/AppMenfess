import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  final AppProvider provider;
  const AuthScreen({super.key, required this.provider});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
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

  void _toggleMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

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
          msg = 'Email kamu belum dikonfirmasi. Cek kotak masuk/spam email kamu.';
        } else if (msg.contains('invalid_credentials')) {
          msg = 'Email atau kata sandi salah.';
        } else if (msg.contains('rate limit exceeded')) {
          msg = 'Terlalu banyak mencoba. Tunggu beberapa menit ya.';
        }
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 20),
                  _buildToggle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: NeoBrutalismTheme.yellow,
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidth,
            ),
            boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
          ),
          child: const Icon(
            Icons.bolt,
            size: 44,
            color: NeoBrutalismTheme.black,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? 'SELAMAT DATANG\nKEMBALI 👋' : 'BUAT AKUN\nBARU ✨',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.black,
            height: 1.2,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NeoBrutalismTheme.blue,
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidthThin,
            ),
          ),
          child: Text(
            _isLogin
                ? 'Masuk untuk lanjut berbagi menfess anonim'
                : 'Daftar sekarang untuk mulai mengirim menfess',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: NeoBrutalismTheme.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field (register only)
            if (!_isLogin) ...[
              _AuthField(
                controller: _displayNameController,
                hint: 'NAMA TAMPILAN',
                icon: Icons.person,
                validator: (v) =>
                    v != null && v.length >= 3 ? null : 'Nama minimal 3 karakter',
              ),
              const SizedBox(height: 16),
            ],

            // Email
            _AuthField(
              controller: _emailController,
              hint: 'ALAMAT EMAIL',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Email tidak valid',
            ),

            const SizedBox(height: 16),

            // Password
            _AuthField(
              controller: _passwordController,
              hint: 'KATA SANDI',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: NeoBrutalismTheme.black,
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) =>
                  v != null && v.length >= 6 ? null : 'Sandi minimal 6 karakter',
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),

            // Submit button
            _BrutalButton(
              label: _isLogin ? 'MASUK' : 'DAFTAR SEKARANG',
              icon: _isLogin ? Icons.login : Icons.person_add,
              loading: _loading,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NeoBrutalismTheme.black,
          ),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.yellow,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: 2,
              ),
            ),
            child: Text(
              _isLogin ? 'DAFTAR' : 'MASUK',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Input Field
// ─────────────────────────────────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        color: NeoBrutalismTheme.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: NeoBrutalismTheme.black.withOpacity(0.4),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: NeoBrutalismTheme.black, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: NeoBrutalismTheme.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.blue,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.red,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.red,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        errorStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: NeoBrutalismTheme.red,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Banner
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.red,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: NeoBrutalismTheme.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: NeoBrutalismTheme.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brutal Button
// ─────────────────────────────────────────────────────────────────────────────
class _BrutalButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  const _BrutalButton({
    required this.label,
    required this.icon,
    this.loading = false,
    required this.onTap,
  });

  @override
  State<_BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<_BrutalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.loading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.loading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.yellow,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: NeoBrutalismTheme.black,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: NeoBrutalismTheme.black,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
