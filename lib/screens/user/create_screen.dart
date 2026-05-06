import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class CreateScreen extends StatefulWidget {
  final AppProvider provider;
  const CreateScreen({super.key, required this.provider});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;
  bool _isThreeDayExpiry = true;
  int _charCount = 0;
  static const int _maxChars = 750;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _maxChars) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSending = true);
    final success = await widget.provider.createMenfess(text);
    setState(() => _isSending = false);

    if (!mounted) return;
    if (success) {
      _controller.clear();
      _focusNode.unfocus();
      showSnack(context, '✅ Menfess berhasil dikirim!');
    } else {
      showSnack(context, '❌ Gagal. Kuota harian habis atau terjadi error.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverLimit = _charCount > _maxChars;
    final isEmpty = _controller.text.trim().isEmpty;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildInputCard(isOverLimit),
                        const SizedBox(height: 16),
                        _buildBottomRow(isOverLimit),
                        const SizedBox(height: 24),
                        _buildSendButton(isEmpty, isOverLimit),
                        const SizedBox(height: 20),
                        _buildQuotaCard(),
                        const SizedBox(height: 16),
                        _buildTipsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.black,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidthThin,
              ),
            ),
            child: const Icon(
              Icons.add_comment,
              size: 22,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TULIS MENFESS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APA YANG SEDANG\nKAMU PIKIRKAN? 💭',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
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
            'Identitasmu tetap rahasia selamanya.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: NeoBrutalismTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(bool isOverLimit) {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: isOverLimit
              ? NeoBrutalismTheme.red
              : (_focusNode.hasFocus
                  ? NeoBrutalismTheme.blue
                  : NeoBrutalismTheme.black),
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: 10,
        minLines: 8,
        onTap: () => setState(() {}),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: NeoBrutalismTheme.black,
        ),
        decoration: InputDecoration(
          hintText: 'Ceritakan sesuatu...',
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: NeoBrutalismTheme.black.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildBottomRow(bool isOverLimit) {
    final progress = (_charCount / _maxChars).clamp(0.0, 1.0);
    return Row(
      children: [
        // Expiry toggle
        _ToggleButton(
          label: 'EXPIRED 3 HARI',
          selected: _isThreeDayExpiry,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isThreeDayExpiry = !_isThreeDayExpiry);
          },
        ),
        const Spacer(),
        // Char counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOverLimit
                ? NeoBrutalismTheme.red
                : (progress > 0.8
                    ? NeoBrutalismTheme.orange
                    : NeoBrutalismTheme.yellow),
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidthThin,
            ),
          ),
          child: Text(
            '$_charCount/$_maxChars',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isOverLimit || progress > 0.8
                  ? NeoBrutalismTheme.white
                  : NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(bool isEmpty, bool isOverLimit) {
    final disabled = _isSending || isEmpty || isOverLimit;
    return _BrutalButton(
      label: 'KIRIM KE FEED',
      icon: Icons.send,
      disabled: disabled,
      loading: _isSending,
      onTap: disabled ? null : _send,
    );
  }

  Widget _buildQuotaCard() {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final used = widget.provider.todayPostCount;
        const max = 5;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NeoBrutalismTheme.white,
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidth,
            ),
            boxShadow: [NeoBrutalismTheme.hardShadow()],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.blue,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidthThin,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 22,
                  color: NeoBrutalismTheme.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KUOTA HARIAN',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$used dari $max menfess terpakai',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: used >= max
                      ? NeoBrutalismTheme.red
                      : NeoBrutalismTheme.yellow,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidthThin,
                  ),
                ),
                child: Text(
                  '$used/$max',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: used >= max
                        ? NeoBrutalismTheme.white
                        : NeoBrutalismTheme.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                size: 20,
                color: NeoBrutalismTheme.black,
              ),
              const SizedBox(width: 8),
              Text(
                'TIPS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Pesan bersifat anonim — identitasmu tidak terlihat\n'
            '• Menfess akan hilang otomatis sesuai waktu expiry\n'
            '• Kuota 5 menfess per hari (reset jam 02:00 WIB)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Components
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleButton extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
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
        padding: EdgeInsets.fromLTRB(
          12 + (_pressed ? 3 : 0),
          8 + (_pressed ? 3 : 0),
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: widget.selected
              ? NeoBrutalismTheme.blue
              : NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.selected ? Icons.check_circle : Icons.radio_button_off,
              size: 18,
              color: widget.selected
                  ? NeoBrutalismTheme.white
                  : NeoBrutalismTheme.black,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: widget.selected
                    ? NeoBrutalismTheme.white
                    : NeoBrutalismTheme.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrutalButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool disabled;
  final bool loading;
  final VoidCallback? onTap;

  const _BrutalButton({
    required this.label,
    required this.icon,
    this.disabled = false,
    this.loading = false,
    this.onTap,
  });

  @override
  State<_BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<_BrutalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled || widget.loading
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled || widget.loading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
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
          color: widget.disabled
              ? NeoBrutalismTheme.black.withOpacity(0.3)
              : NeoBrutalismTheme.blue,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed || widget.disabled
              ? []
              : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: NeoBrutalismTheme.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: widget.disabled
                          ? NeoBrutalismTheme.black.withOpacity(0.5)
                          : NeoBrutalismTheme.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: widget.disabled
                            ? NeoBrutalismTheme.black.withOpacity(0.5)
                            : NeoBrutalismTheme.white,
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
