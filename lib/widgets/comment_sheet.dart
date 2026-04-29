import 'package:flutter/material.dart';
import '../models/menfess_model.dart';
import '../models/comment_model.dart';
import '../providers/app_provider.dart';
import '../core/utils.dart';

/// Bottom sheet untuk melihat & menambah komentar.
class CommentSheet extends StatefulWidget {
  final MenfessModel menfess;
  final AppProvider provider;

  const CommentSheet({
    super.key,
    required this.menfess,
    required this.provider,
  });

  static Future<void> show(
    BuildContext context, {
    required MenfessModel menfess,
    required AppProvider provider,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(menfess: menfess, provider: provider),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load comments if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.loadComments(widget.menfess.id);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final success = await widget.provider.addComment(widget.menfess.id, text);
    if (success && mounted) {
      _inputController.clear();
      FocusScope.of(context).unfocus();
      // Scroll to bottom after new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final menfessId = widget.menfess.id;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: mq.size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(
                  'Komentar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Original post snippet ─────────────────────────────────────────
          Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              widget.menfess.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Comment list ──────────────────────────────────────────────────
          Flexible(
            child: ListenableBuilder(
              listenable: widget.provider,
              builder: (context, _) {
                if (widget.provider.isCommentLoading(menfessId)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final comments = widget.provider.commentsFor(menfessId);
                if (comments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada komentar',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.45),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jadilah yang pertama!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _CommentTile(comment: comments[i]),
                );
              },
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                mq.viewInsets.bottom > 0 ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: widget.provider.userId != null
                  ? ListenableBuilder(
                      listenable: widget.provider,
                      builder: (context, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                maxLines: 3,
                                minLines: 1,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'Tulis komentar anonim...',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                    fontSize: 14,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _SendButton(
                              isLoading:
                                  widget.provider.isSubmittingComment,
                              onPressed: _submit,
                            ),
                          ],
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Login untuk berkomentar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.45),
                          fontSize: 13,
                        ),
                      ),
                    ),
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
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 14,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Anonim',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo(comment.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  comment.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: 42,
        height: 42,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            backgroundColor: theme.colorScheme.primary,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, size: 18),
        ),
      ),
    );
  }
}
