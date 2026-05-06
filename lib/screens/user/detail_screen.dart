import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menfess_model.dart';
import '../../models/comment_model.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../core/neo_brutalism_theme.dart';
import '../../widgets/user/share_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class DetailScreen extends StatefulWidget {
  final MenfessModel menfess;
  final AppProvider provider;

  const DetailScreen({
    super.key,
    required this.menfess,
    required this.provider,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.provider.loadComments(widget.menfess.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    final success = await widget.provider.addComment(widget.menfess.id, text);
    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      showSnack(context, '✅ Komentar terkirim');
    }
  }

  Future<void> _toggleLike() async {
    HapticFeedback.selectionClick();
    await widget.provider.toggleLike(widget.menfess.id);
  }

  Future<void> _toggleBookmark() async {
    HapticFeedback.selectionClick();
    await widget.provider.toggleBookmark(widget.menfess.id);
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
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(child: _buildPostCard()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: NeoBrutalismTheme.blue,
                                  border: Border.all(
                                    color: NeoBrutalismTheme.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble,
                                  size: 14,
                                  color: NeoBrutalismTheme.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'KOMENTAR',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: NeoBrutalismTheme.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListenableBuilder(
                        listenable: widget.provider,
                        builder: (context, _) {
                          if (widget.provider.isCommentLoading(widget.menfess.id)) {
                            return const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: NeoBrutalismTheme.blue,
                                  ),
                                ),
                              ),
                            );
                          }

                          final comments = widget.provider.commentsFor(widget.menfess.id);
                          if (comments.isEmpty) {
                            return SliverToBoxAdapter(child: _EmptyComments());
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _CommentTile(comment: comments[i]),
                                childCount: comments.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildCommentInput(),
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
          _BackButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: 12),
          Text(
            'DETAIL MENFESS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.blue,
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: NeoBrutalismTheme.borderWidthThin,
                    ),
                  ),
                  child: const Icon(Icons.person, size: 26, color: NeoBrutalismTheme.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANON#${widget.menfess.userId.length >= 4 ? widget.menfess.userId.substring(0, 4) : widget.menfess.userId}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        timeAgo(widget.menfess.createdAt),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NeoBrutalismTheme.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.menfess.message,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatChip(
                  icon: Icons.visibility,
                  label: '${widget.menfess.viewCount}',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.chat_bubble,
                  label: '${widget.menfess.commentCount}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 3, color: NeoBrutalismTheme.black),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: widget.provider,
              builder: (context, _) {
                final liked = widget.provider.isLiked(widget.menfess.id);
                final bookmarked = widget.provider.isBookmarked(widget.menfess.id);
                final likeCount = widget.provider.likeCount(widget.menfess);

                return Row(
                  children: [
                    _ActionButton(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      label: '$likeCount',
                      bgColor: liked ? NeoBrutalismTheme.red : NeoBrutalismTheme.yellow,
                      onTap: _toggleLike,
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      label: '',
                      bgColor: bookmarked ? NeoBrutalismTheme.blue : NeoBrutalismTheme.white,
                      onTap: _toggleBookmark,
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.share,
                      label: '',
                      bgColor: NeoBrutalismTheme.green,
                      onTap: () => ShareBottomSheet.show(context, widget.menfess),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border(
          top: BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.white,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidthThin,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ListenableBuilder(
              listenable: widget.provider,
              builder: (context, _) {
                final isSubmitting = widget.provider.isSubmittingComment;
                return _SendButton(
                  loading: isSubmitting,
                  onTap: isSubmitting ? null : _submitComment,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
        width: 44,
        height: 44,
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.black,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: const Icon(Icons.arrow_back, size: 22, color: NeoBrutalismTheme.yellow),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.yellow,
        border: Border.all(color: NeoBrutalismTheme.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NeoBrutalismTheme.black),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
          12 + (_pressed ? 2 : 0),
          8 + (_pressed ? 2 : 0),
          12,
          8,
        ),
        decoration: BoxDecoration(
          color: widget.bgColor,
          border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 18, color: NeoBrutalismTheme.black),
            if (widget.label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _SendButton({required this.loading, this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
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
        width: 48,
        height: 48,
        margin: EdgeInsets.only(
          top: _pressed ? 3 : 0,
          left: _pressed ? 3 : 0,
        ),
        decoration: BoxDecoration(
          color: widget.loading ? NeoBrutalismTheme.black.withOpacity(0.3) : NeoBrutalismTheme.blue,
          border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
          boxShadow: _pressed || widget.loading ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: NeoBrutalismTheme.white,
                  ),
                )
              : const Icon(Icons.send, size: 20, color: NeoBrutalismTheme.white),
        ),
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.yellow,
              border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidth),
              boxShadow: [NeoBrutalismTheme.hardShadow()],
            ),
            child: const Icon(Icons.chat_bubble, size: 36, color: NeoBrutalismTheme.black),
          ),
          const SizedBox(height: 20),
          Text(
            'BELUM ADA KOMENTAR',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadilah yang pertama berkomentar!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.blue,
              border: Border.all(color: NeoBrutalismTheme.black, width: 2),
            ),
            child: const Icon(Icons.person, size: 18, color: NeoBrutalismTheme.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ANONIM',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo(comment.createdAt),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.white,
                    border: Border.all(color: NeoBrutalismTheme.black, width: 2),
                  ),
                  child: Text(
                    comment.text,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
