import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../models/menfess_model.dart';
import '../../widgets/user/menfess_card.dart';
import '../../widgets/user/menfess_skeleton.dart';
import '../../core/neo_brutalism_theme.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN — Neo-Brutalism Style
// High contrast, thick borders, hard shadows, bold typography
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final AppProvider provider;
  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  bool _isNearBottom = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final isNear = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500;
    if (isNear && !_isNearBottom) {
      _isNearBottom = true;
      if (widget.provider.hasMore && !widget.provider.isLoading) {
        widget.provider.loadMoreMenfess();
      }
    } else if (!isNear && _isNearBottom) {
      _isNearBottom = false;
    }
  }

  void _handleRetry() => widget.provider.fetchMenfess();

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                ListenableBuilder(
                  listenable: widget.provider,
                  builder: (_, a) => _ErrorBanner(
                    error: widget.provider.error,
                    onRetry: widget.provider.error != null ? _handleRetry : null,
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.provider,
                    builder: (context, _) => _buildFeed(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
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
          // Logo
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
              Icons.bolt,
              size: 24,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'MENFESS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          // Search
          _BrutalIconButton(
            icon: Icons.search,
            bgColor: NeoBrutalismTheme.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(provider: widget.provider),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Refresh
          ListenableBuilder(
            listenable: widget.provider,
            builder: (_, a) => _BrutalIconButton(
              icon: Icons.refresh,
              bgColor: NeoBrutalismTheme.blue,
              iconColor: NeoBrutalismTheme.white,
              loading: widget.provider.isLoading && widget.provider.currentPage == 0,
              onTap: widget.provider.isLoading
                  ? null
                  : () => widget.provider.fetchMenfess(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feed builder ──────────────────────────────────────────────────────────
  Widget _buildFeed() {
    final isFirstLoad = widget.provider.isLoading && widget.provider.currentPage == 0;
    final list = widget.provider.menfessList;

    // Skeleton during first load
    if (isFirstLoad && list.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: 5,
        itemBuilder: (_, a) => const MenfessSkeleton(),
      );
    }

    // Empty state
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => widget.provider.fetchMenfess(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _EmptyState(),
        ),
      );
    }

    // Feed list
    return RefreshIndicator(
      onRefresh: () async {
        await widget.provider.fetchMenfess();
        await widget.provider.fetchHotToday();
      },
      color: NeoBrutalismTheme.blue,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Hot Today Section ──────────────────────────────────────────────
          if (widget.provider.hotMenfess.isNotEmpty)
            SliverToBoxAdapter(
              child: _HotSection(
                hotMenfess: widget.provider.hotMenfess,
                provider: widget.provider,
              ),
            ),

          // ── Main Feed ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i == list.length) {
                    return _LoadMoreIndicator(
                      isLoading: widget.provider.isLoading,
                      onLoadMore: widget.provider.loadMoreMenfess,
                    );
                  }
                  return MenfessCard(
                    menfess: list[i],
                    provider: widget.provider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            menfess: list[i],
                            provider: widget.provider,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: list.length + (widget.provider.hasMore ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hot Section
// ─────────────────────────────────────────────────────────────────────────────
class _HotSection extends StatelessWidget {
  final List<MenfessModel> hotMenfess;
  final AppProvider provider;

  const _HotSection({required this.hotMenfess, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.red,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.whatshot,
                      size: 18,
                      color: NeoBrutalismTheme.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LAGI RAME',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: hotMenfess.length,
            itemBuilder: (context, i) {
              final m = hotMenfess[i];
              return _HotCard(menfess: m, provider: provider);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HotCard extends StatefulWidget {
  final MenfessModel menfess;
  final AppProvider provider;

  const _HotCard({required this.menfess, required this.provider});

  @override
  State<_HotCard> createState() => _HotCardState();
}

class _HotCardState extends State<_HotCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              menfess: widget.menfess,
              provider: widget.provider,
            ),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 280,
        margin: EdgeInsets.only(
          right: 12,
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.yellow,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.black,
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'ANON#${widget.menfess.userId.length >= 4 ? widget.menfess.userId.substring(0, 4) : widget.menfess.userId}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.yellow,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.favorite, size: 16, color: NeoBrutalismTheme.red),
                const SizedBox(width: 4),
                Text(
                  '${widget.menfess.likeCount}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                widget.menfess.message,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────
class _BrutalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  final Color bgColor;
  final Color iconColor;

  const _BrutalIconButton({
    required this.icon,
    this.onTap,
    this.loading = false,
    this.bgColor = NeoBrutalismTheme.white,
    this.iconColor = NeoBrutalismTheme.black,
  });

  @override
  State<_BrutalIconButton> createState() => _BrutalIconButtonState();
}

class _BrutalIconButtonState extends State<_BrutalIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
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
          color: widget.bgColor,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Center(
          child: widget.loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: widget.iconColor,
                  ),
                )
              : Icon(
                  widget.icon,
                  size: 22,
                  color: widget.iconColor,
                ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const _ErrorBanner({this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.red,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow()],
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: NeoBrutalismTheme.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error!,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: NeoBrutalismTheme.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.white,
                    border: Border.all(color: NeoBrutalismTheme.black, width: 2),
                  ),
                  child: Text(
                    'RETRY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: NeoBrutalismTheme.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.yellow,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidth,
              ),
              boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
            ),
            child: const Icon(
              Icons.inbox,
              size: 48,
              color: NeoBrutalismTheme.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BELUM ADA MENFESS',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jadilah yang pertama berbagi perasaanmu!',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreIndicator extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;
  const _LoadMoreIndicator({required this.isLoading, required this.onLoadMore});

  @override
  State<_LoadMoreIndicator> createState() => _LoadMoreIndicatorState();
}

class _LoadMoreIndicatorState extends State<_LoadMoreIndicator> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: widget.isLoading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: NeoBrutalismTheme.blue,
                ),
              ),
            )
          : GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) {
                setState(() => _pressed = false);
                widget.onLoadMore();
              },
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 50,
                margin: EdgeInsets.only(
                  top: _pressed ? 4 : 0,
                  left: _pressed ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.blue,
                  border: Border.all(
                    color: NeoBrutalismTheme.black,
                    width: NeoBrutalismTheme.borderWidth,
                  ),
                  boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.expand_more,
                        size: 22,
                        color: NeoBrutalismTheme.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MUAT LEBIH BANYAK',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
