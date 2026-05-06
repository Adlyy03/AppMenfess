import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menfess_model.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MENFESS CARD — Neo-Brutalism Style
// Thick borders, hard shadows, bold typography, pressed effect
// ─────────────────────────────────────────────────────────────────────────────
class MenfessCard extends StatefulWidget {
  final MenfessModel menfess;
  final AppProvider provider;
  final VoidCallback? onTap;

  const MenfessCard({
    super.key,
    required this.menfess,
    required this.provider,
    this.onTap,
  });

  @override
  State<MenfessCard> createState() => _MenfessCardState();
}

class _MenfessCardState extends State<MenfessCard> {
  bool _cardPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.trackView(widget.menfess.id);
    });
  }

  Future<void> _onLikeTap() async {
    HapticFeedback.lightImpact();
    await widget.provider.toggleLike(widget.menfess.id);
  }

  void _onBookmarkTap() {
    HapticFeedback.selectionClick();
    widget.provider.toggleBookmark(widget.menfess.id);
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = DateTime.now().isAfter(widget.menfess.expiresAt);
    final isHot = widget.menfess.likeCount >= 10;

    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final menfessId = widget.menfess.id;
        final liked = widget.provider.isLiked(menfessId);
        final likeLoading = widget.provider.isLikeLoading(menfessId);
        final bookmarked = widget.provider.isBookmarked(menfessId);
        final bookmarkLoading = widget.provider.isBookmarkLoading(menfessId);
        final displayedLikeCount = widget.provider.likeCount(widget.menfess);
        final commentCount = widget.menfess.commentCount;
        final viewCount = widget.menfess.viewCount;

        return GestureDetector(
          onTapDown: (_) => setState(() => _cardPressed = true),
          onTapUp: (_) {
            setState(() => _cardPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _cardPressed = false),
          child: Opacity(
            opacity: isExpired ? 0.6 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.fromLTRB(
                16 + (_cardPressed ? 4 : 0),
                8 + (_cardPressed ? 4 : 0),
                16,
                8,
              ),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isHot ? NeoBrutalismTheme.red : NeoBrutalismTheme.white,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidth,
                ),
                boxShadow: _cardPressed ? [] : [NeoBrutalismTheme.hardShadow()],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────
                  Row(
                    children: [
                      _AnonAvatar(isHot: isHot),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ANON#${widget.menfess.userId.length >= 4 ? widget.menfess.userId.substring(0, 4) : widget.menfess.userId}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isHot
                                        ? NeoBrutalismTheme.white
                                        : NeoBrutalismTheme.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (isHot) ...[
                                  const SizedBox(width: 8),
                                  _HotBadge(),
                                ],
                              ],
                            ),
                            Text(
                              timeAgo(widget.menfess.createdAt),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isHot
                                    ? NeoBrutalismTheme.white.withOpacity(0.8)
                                    : NeoBrutalismTheme.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ExpiryBadge(menfess: widget.menfess, isHot: isHot),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Message ──────────────────────────────────
                  Text(
                    widget.menfess.message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: isHot
                          ? NeoBrutalismTheme.white
                          : NeoBrutalismTheme.black,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── View count ───────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: isHot
                            ? NeoBrutalismTheme.white.withOpacity(0.8)
                            : NeoBrutalismTheme.black.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_fmt(viewCount)} DILIHAT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isHot
                              ? NeoBrutalismTheme.white.withOpacity(0.8)
                              : NeoBrutalismTheme.black.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    height: 3,
                    color: isHot
                        ? NeoBrutalismTheme.white.withOpacity(0.3)
                        : NeoBrutalismTheme.black.withOpacity(0.2),
                  ),
                  const SizedBox(height: 14),

                  // ── Actions ──────────────────────────────────
                  Row(
                    children: [
                      // Like
                      _ActionBtn(
                        icon: liked ? Icons.favorite : Icons.favorite_border,
                        label: _fmt(displayedLikeCount),
                        color: liked
                            ? NeoBrutalismTheme.red
                            : (isHot
                                ? NeoBrutalismTheme.white
                                : NeoBrutalismTheme.black),
                        bgColor: liked
                            ? NeoBrutalismTheme.yellow
                            : (isHot
                                ? NeoBrutalismTheme.black
                                : NeoBrutalismTheme.yellow),
                        loading: likeLoading,
                        onTap: _onLikeTap,
                      ),
                      const SizedBox(width: 12),
                      // Comment
                      _ActionBtn(
                        icon: Icons.chat_bubble,
                        label: _fmt(commentCount),
                        color: isHot
                            ? NeoBrutalismTheme.white
                            : NeoBrutalismTheme.black,
                        bgColor: isHot
                            ? NeoBrutalismTheme.black
                            : NeoBrutalismTheme.blue,
                        onTap: widget.onTap,
                      ),
                      const SizedBox(width: 12),
                      // Bookmark
                      _ActionBtn(
                        icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        label: '',
                        color: bookmarked
                            ? NeoBrutalismTheme.yellow
                            : (isHot
                                ? NeoBrutalismTheme.white
                                : NeoBrutalismTheme.black),
                        bgColor: bookmarked
                            ? NeoBrutalismTheme.black
                            : (isHot
                                ? NeoBrutalismTheme.black
                                : NeoBrutalismTheme.white),
                        loading: bookmarkLoading,
                        onTap: _onBookmarkTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _AnonAvatar extends StatelessWidget {
  final bool isHot;
  const _AnonAvatar({this.isHot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isHot ? NeoBrutalismTheme.yellow : NeoBrutalismTheme.blue,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidthThin,
        ),
      ),
      child: Icon(
        isHot ? Icons.whatshot : Icons.person,
        size: 24,
        color: NeoBrutalismTheme.black,
      ),
    );
  }
}

class _HotBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.whatshot, size: 12, color: NeoBrutalismTheme.black),
          const SizedBox(width: 4),
          Text(
            'HOT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final MenfessModel menfess;
  final bool isHot;
  const _ExpiryBadge({required this.menfess, this.isHot = false});

  @override
  Widget build(BuildContext context) {
    final remaining = menfess.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    final isUrgent = remaining.inHours < 3;
    final label = remaining.inHours < 1
        ? '${remaining.inMinutes}M'
        : '${remaining.inHours}H';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? NeoBrutalismTheme.orange
            : (isHot ? NeoBrutalismTheme.black : NeoBrutalismTheme.yellow),
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: isUrgent
                ? NeoBrutalismTheme.white
                : (isHot ? NeoBrutalismTheme.white : NeoBrutalismTheme.black),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isUrgent
                  ? NeoBrutalismTheme.white
                  : (isHot ? NeoBrutalismTheme.white : NeoBrutalismTheme.black),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final bool loading;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.loading = false,
    this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.loading || widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.loading || widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.fromLTRB(
          10 + (_pressed ? 2 : 0),
          6 + (_pressed ? 2 : 0),
          10,
          6,
        ),
        decoration: BoxDecoration(
          color: widget.bgColor,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.color,
                    ),
                  )
                : Icon(widget.icon, size: 18, color: widget.color),
            if (widget.label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
