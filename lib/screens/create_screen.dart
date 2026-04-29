import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../core/utils.dart';

class CreateScreen extends StatefulWidget {
  final AppProvider provider;
  const CreateScreen({super.key, required this.provider});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _controller = TextEditingController();
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
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _maxChars) return;

    setState(() => _isSending = true);
    final success = await widget.provider.createMenfess(text);
    setState(() => _isSending = false);

    if (!mounted) return;
    if (success) {
      _controller.clear();
      showSnack(context, '⚡ Menfess SKANIC Terkirim!');
    } else {
      showSnack(context, '❌ Gagal. Kuota harian habis.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverLimit = _charCount > _maxChars;
    final isEmpty = _controller.text.trim().isEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ───────────────────────────────────────
                        _buildHeader(theme),
                        const SizedBox(height: 32),

                        // ── Input Area ───────────────────────────────────
                        _buildInputArea(theme, isOverLimit),
                        const SizedBox(height: 12),
                        
                        // ── Char Counter & Expiry ────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildExpiryToggle(theme),
                            Text(
                              '$_charCount / $_maxChars',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isOverLimit ? theme.colorScheme.error : theme.colorScheme.onSurface.withOpacity(0.4),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Send Button ──────────────────────────────────
                        _buildSendButton(theme, isEmpty, isOverLimit),
                        const SizedBox(height: 24),

                        // ── Footer Info ──────────────────────────────────
                        _TipsCard(theme: theme),
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

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add_comment_rounded, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tulis Menfess',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            Text(
              'Identitasmu tetap rahasia selamanya.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isOverLimit) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverLimit ? theme.colorScheme.error : theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controller,
        maxLines: 12,
        minLines: 8,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Apa yang sedang kamu pikirkan?',
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildExpiryToggle(ThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _isThreeDayExpiry = !_isThreeDayExpiry),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isThreeDayExpiry ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: _isThreeDayExpiry ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 8),
            Text(
              'Expired dalam 3 hari',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _isThreeDayExpiry ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme, bool isEmpty, bool isOverLimit) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: (isEmpty || isOverLimit || _isSending) 
            ? null 
            : LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: (isEmpty || isOverLimit || _isSending)
            ? null
            : [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: FilledButton(
        onPressed: (_isSending || isEmpty || isOverLimit) ? null : _send,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSending
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text('Kirim ke SKANIC Feed', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
      ),
    );
  }
}

class _QuotaRow extends StatelessWidget {
  final AppProvider provider;
  const _QuotaRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 3 dots for quota
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded,
            size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          'Kuota Harian: ${provider.todayPostCount} / 5 digunakan',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.55),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  final ThemeData theme;
  const _TipsCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Tips',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• Pesan bersifat anonim — identitasmu tidak akan terlihat\n'
            '• Menfess akan hilang otomatis setelah 24 jam\n'
            '• Kuota 5 menfess per hari (Reset Jam 02:00 WIB)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
