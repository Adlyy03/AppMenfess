import 'package:flutter/material.dart';
import '../providers/app_provider.dart';
import '../models/menfess_model.dart';
import '../widgets/menfess_card.dart';
import '../widgets/menfess_skeleton.dart';
import '../widgets/comment_sheet.dart';

class HomeScreen extends StatefulWidget {
  final AppProvider provider;
  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  late ScrollController _scrollController;
  bool _isNearBottom = false;
  bool _showSearchBar = false;

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
    _searchController.dispose();
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

  void _handleRetry() => widget.provider.fetchMenfess(
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive: centre constrain on wide screens (web)
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: Column(
              children: [
                // ── AppBar custom ────────────────────────────────────────
                _buildAppBar(theme),

                // ── Search bar (animated) ────────────────────────────────
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _showSearchBar
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _buildSearchBar(theme),
                  secondChild: const SizedBox(height: 4),
                ),

                // ── Error banner ─────────────────────────────────────────
                ListenableBuilder(
                  listenable: widget.provider,
                  builder: (_, __) => _ErrorBanner(
                    error: widget.provider.error,
                    onRetry: widget.provider.error != null ? _handleRetry : null,
                  ),
                ),

                // ── Feed ─────────────────────────────────────────────────
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.provider,
                    builder: (context, _) => _buildFeed(theme),
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
  Widget _buildAppBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
      child: Row(
        children: [
          // Logo + title
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.message_rounded,
                size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'Menfess',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Search toggle
          IconButton(
            tooltip: 'Cari',
            icon: Icon(
              _showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
              color: _showSearchBar
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            onPressed: () {
              setState(() => _showSearchBar = !_showSearchBar);
              if (!_showSearchBar) {
                _searchController.clear();
                widget.provider.fetchMenfess();
              }
            },
          ),
          // Refresh
          ListenableBuilder(
            listenable: widget.provider,
            builder: (_, __) => IconButton(
              tooltip: 'Refresh',
              icon: widget.provider.isLoading && widget.provider.currentPage == 0
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
              onPressed: widget.provider.isLoading
                  ? null
                  : () => widget.provider.fetchMenfess(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari di Menfess SKANIC...',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        widget.provider.fetchMenfess();
                        setState(() {});
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (val) => widget.provider.fetchMenfess(
              search: val.isEmpty ? null : val,
            ),
          ),
          const SizedBox(height: 12),
          _buildFilterChips(theme),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = ['Terbaru', 'Hot Today', 'Trending', 'Most Viewed'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = i == 0; // Fake UI selection
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[i]),
              selected: isSelected,
              onSelected: (val) {},
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              backgroundColor: Colors.transparent,
              selectedColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Feed builder ──────────────────────────────────────────────────────────
  Widget _buildFeed(ThemeData theme) {
    final isFirstLoad =
        widget.provider.isLoading && widget.provider.currentPage == 0;
    final list = widget.provider.menfessList;

    // Skeleton during first load
    if (isFirstLoad && list.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 80),
        itemCount: 5,
        itemBuilder: (_, __) => const MenfessSkeleton(),
      );
    }

    // Empty state
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => widget.provider.fetchMenfess(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _EmptyState(hasSearch: _searchController.text.isNotEmpty),
        ),
      );
    }

    // Feed list
    return RefreshIndicator(
      onRefresh: () async {
        await widget.provider.fetchMenfess();
        await widget.provider.fetchHotToday();
      },
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Hot Today Section ──────────────────────────────────────────────
          if (_searchController.text.isEmpty && widget.provider.hotMenfess.isNotEmpty)
            SliverToBoxAdapter(
              child: _HotSection(
                hotMenfess: widget.provider.hotMenfess,
                provider: widget.provider,
              ),
            ),

          // ── Main Feed ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 100),
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

class _HotSection extends StatelessWidget {
  final List<MenfessModel> hotMenfess;
  final AppProvider provider;

  const _HotSection({required this.hotMenfess, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded,
                  size: 20, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                'Lagi Rame Hari Ini',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const Spacer(),
              Text(
                'Lihat semua',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
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
              return Container(
                width: 290,
                margin: const EdgeInsets.only(right: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.secondary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1), width: 1.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      provider.loadComments(m.id);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommentSheet(
                          menfess: m,
                          provider: provider,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Anon#${m.userId.length >= 4 ? m.userId.substring(0, 4) : m.userId}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.favorite_rounded,
                                  size: 14, color: theme.colorScheme.error),
                              const SizedBox(width: 4),
                              Text(
                                '${m.likeCount}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: Text(
                              m.message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Divider(
          indent: 20,
          endIndent: 20,
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const _ErrorBanner({this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: theme.colorScheme.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: onRetry,
                child: Text(
                  'Coba lagi',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
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
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.inbox_outlined,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasSearch ? 'Tidak ditemukan' : 'Belum ada menfess',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Coba kata kunci lain.'
                : 'Jadilah yang pertama berbagi perasaanmu!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLoadMore;
  const _LoadMoreIndicator(
      {required this.isLoading, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: const Text('Muat lebih banyak'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                    color: theme.colorScheme.outlineVariant),
              ),
            ),
    );
  }
}
