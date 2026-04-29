import 'package:flutter/material.dart';
import '../models/menfess_model.dart';
import '../providers/app_provider.dart';
import '../core/utils.dart';
import 'comment_sheet.dart';

/// Interactive menfess card with optimistic like, comment, and view tracking.
class MenfessCard extends StatefulWidget {
  final MenfessModel menfess;
  final AppProvider provider;

  const MenfessCard({
    super.key,
    required this.menfess,
    required this.provider,
  });

  @override
  State<MenfessCard> createState() => _MenfessCardState();
}

class _MenfessCardState extends State<MenfessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnim;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _likeScale = _likeAnim;

    // Track view once per session when card appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.trackView(widget.menfess.id);
    });
  }

  @override
  void dispose() {
    _likeAnim.dispose();
    super.dispose();
  }

  Future<void> _onLikeTap() async {
    // Micro-animation: compress then spring back
    await _likeAnim.reverse();
    _likeAnim.forward();
    await widget.provider.toggleLike(widget.menfess.id);
  }

  void _onCommentTap() {
    CommentSheet.show(
      context,
      menfess: widget.menfess,
      provider: widget.provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = DateTime.now().isAfter(widget.menfess.expiresAt);
    final isHot = widget.menfess.likeCount >= 10;

    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final menfessId = widget.menfess.id;
        final liked = widget.provider.isLiked(menfessId);
        final likeLoading = widget.provider.isLikeLoading(menfessId);
        final displayedLikeCount = widget.provider.likeCount(widget.menfess);
        final commentCount = widget.menfess.commentCount;
        final viewCount = widget.menfess.viewCount;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Opacity(
                opacity: isExpired ? 0.6 : 1.0,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    onTap: _onCommentTap,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ───────────────────────────────────────────────
                          Row(
                            children: [
                              _AnonAvatar(theme: theme),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Anon#${widget.menfess.userId.length >= 4 ? widget.menfess.userId.substring(0, 4) : widget.menfess.userId}',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        if (isHot) ...[
                                          const SizedBox(width: 8),
                                          _HotBadge(theme: theme),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      timeAgo(widget.menfess.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _ExpiryBadge(menfess: widget.menfess, theme: theme),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Message body ─────────────────────────────────────────
                          Text(
                            widget.menfess.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Social Proof (View Count) ────────────────────────────
                          Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 14, color: theme.colorScheme.primary.withOpacity(0.5)),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatCount(viewCount)} viewed',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.3), height: 1),
                          const SizedBox(height: 12),

                          // ── Action row ───────────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _ActionButton(
                                    icon: liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    label: _formatCount(displayedLikeCount),
                                    color: liked ? const Color(0xFFFF2E63) : theme.colorScheme.onSurface.withOpacity(0.5),
                                    loading: likeLoading,
                                    onTap: _onLikeTap,
                                    scaleAnimation: _likeScale,
                                  ),
                                  const SizedBox(width: 24),
                                  _ActionButton(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    label: _formatCount(commentCount),
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    onTap: _onCommentTap,
                                  ),
                                ],
                              ),
                              // Emoji Picker Placeholder
                              IconButton(
                                icon: Icon(Icons.add_reaction_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                onPressed: () {
                                  // Simple emoji reaction picker logic can go here
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _AnonAvatar extends StatelessWidget {
  final ThemeData theme;
  const _AnonAvatar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, size: 20, color: Colors.white),
    );
  }
}

class _HotBadge extends StatelessWidget {
  final ThemeData theme;
  const _HotBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.tertiary, Colors.orange]),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.whatshot_rounded, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'HOT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final MenfessModel menfess;
  final ThemeData theme;
  const _ExpiryBadge({required this.menfess, required this.theme});

  @override
  Widget build(BuildContext context) {
    final remaining = menfess.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return const SizedBox.shrink();

    final isUrgent = remaining.inHours < 3;
    final label = remaining.inHours < 1
        ? '${remaining.inMinutes}m'
        : '${remaining.inHours}j';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.orange.withOpacity(0.15)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 11,
            color: isUrgent
                ? Colors.orange.shade700
                : theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isUrgent
                  ? Colors.orange.shade700
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onTap;
  final Animation<double>? scaleAnimation;
  final AnimationController? animController;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.loading = false,
    this.onTap,
    this.scaleAnimation,
    this.animController,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: color,
            ),
          )
        : Icon(icon, size: 18, color: color);

    if (scaleAnimation != null) {
      iconWidget = ScaleTransition(scale: scaleAnimation!, child: iconWidget);
    }

    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
