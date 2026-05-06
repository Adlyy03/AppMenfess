import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../core/utils.dart';
import '../../models/menfess_model.dart';
import '../../services/share_service.dart';

class ShareBottomSheet extends StatelessWidget {
  final MenfessModel menfess;

  const ShareBottomSheet({super.key, required this.menfess});

  static Future<void> show(BuildContext context, MenfessModel menfess) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareBottomSheet(menfess: menfess),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: NeoBrutalismTheme.blue,
                      border: Border.all(
                        color: NeoBrutalismTheme.black,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.share,
                      size: 20,
                      color: NeoBrutalismTheme.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'BAGIKAN MENFESS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _CloseButton(onTap: () => Navigator.pop(context)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.yellow.withOpacity(0.3),
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREVIEW:',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${menfess.message.length > 80 ? '${menfess.message.substring(0, 80)}...' : menfess.message}"',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.black,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💬 ${menfess.commentCount} • ❤️ ${menfess.likeCount} • 👀 ${menfess.viewCount}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeoBrutalismTheme.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Share Options
              Text(
                'PILIH CARA BERBAGI:',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Share buttons grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  _ShareOption(
                    icon: Icons.share,
                    label: 'BAGIKAN UMUM',
                    bgColor: NeoBrutalismTheme.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      await ShareService.shareMenfess(menfess);
                      if (context.mounted) {
                        showSnack(context, '📤 Menfess dibagikan!');
                      }
                    },
                  ),
                  _ShareOption(
                    icon: Icons.chat,
                    label: 'WHATSAPP',
                    bgColor: NeoBrutalismTheme.green,
                    onTap: () async {
                      Navigator.pop(context);
                      await ShareService.shareToWhatsApp(menfess);
                      if (context.mounted) {
                        showSnack(context, '💚 Dibagikan ke WhatsApp!');
                      }
                    },
                  ),
                  _ShareOption(
                    icon: Icons.link,
                    label: 'SALIN LINK',
                    bgColor: NeoBrutalismTheme.yellow,
                    onTap: () async {
                      Navigator.pop(context);
                      await ShareService.copyLink(menfess);
                      if (context.mounted) {
                        showSnack(context, '🔗 Link disalin ke clipboard!');
                      }
                    },
                  ),
                  _ShareOption(
                    icon: Icons.qr_code,
                    label: 'QR CODE',
                    bgColor: NeoBrutalismTheme.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showQRCode(context);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Link preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.black.withOpacity(0.05),
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 16,
                      color: NeoBrutalismTheme.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ShareService.generateShareLink(menfess.id),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: NeoBrutalismTheme.black.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    final qrUrl = ShareService.generateQRLink(menfess.id);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeoBrutalismTheme.white,
            border: Border.all(
              color: NeoBrutalismTheme.black,
              width: NeoBrutalismTheme.borderWidth,
            ),
            boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 8, offsetY: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCAN QR CODE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.white,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: 2,
                  ),
                ),
                child: Image.network(
                  qrUrl,
                  width: 200,
                  height: 200,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200,
                    height: 200,
                    color: NeoBrutalismTheme.yellow,
                    child: const Icon(
                      Icons.qr_code,
                      size: 100,
                      color: NeoBrutalismTheme.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan untuk membuka menfess',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_ShareOption> createState() => _ShareOptionState();
}

class _ShareOptionState extends State<_ShareOption> {
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
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.bgColor,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: NeoBrutalismTheme.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
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
        width: 32,
        height: 32,
        margin: EdgeInsets.only(
          top: _pressed ? 2 : 0,
          left: _pressed ? 2 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.red,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: 2,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: NeoBrutalismTheme.white,
        ),
      ),
    );
  }
}