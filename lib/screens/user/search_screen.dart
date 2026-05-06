import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../models/menfess_model.dart';
import '../../widgets/user/menfess_card.dart';
import '../../core/neo_brutalism_theme.dart';
import 'detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class SearchScreen extends StatefulWidget {
  final AppProvider provider;
  const SearchScreen({super.key, required this.provider});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<MenfessModel> _results = [];
  bool _isSearching = false;

  final List<String> _trendingSearches = [
    'cinta',
    'sekolah',
    'ujian',
    'teman',
    'guru',
    'pelajaran',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    HapticFeedback.selectionClick();

    await Future.delayed(const Duration(milliseconds: 500));

    final filtered = widget.provider.menfessList
        .where((m) => m.message.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (mounted) {
      setState(() {
        _results = filtered;
        _isSearching = false;
      });
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
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.white,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidthThin,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (val) => _performSearch(val),
                onSubmitted: (val) => _performSearch(val),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.black,
                ),
                decoration: InputDecoration(
                  hintText: 'CARI MENFESS...',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.black.withOpacity(0.4),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: NeoBrutalismTheme.black,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                              _isSearching = false;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: NeoBrutalismTheme.black,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: NeoBrutalismTheme.blue,
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      if (_results.isEmpty) {
        return _EmptyResults(query: _searchController.text);
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        itemCount: _results.length,
        itemBuilder: (context, i) => MenfessCard(
          menfess: _results[i],
          provider: widget.provider,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  menfess: _results[i],
                  provider: widget.provider,
                ),
              ),
            );
          },
        ),
      );
    }

    return _TrendingSection(
      searches: _trendingSearches,
      onTap: (query) {
        _searchController.text = query;
        _performSearch(query);
      },
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
          border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: const Icon(Icons.arrow_back, size: 22, color: NeoBrutalismTheme.yellow),
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final List<String> searches;
  final Function(String) onTap;

  const _TrendingSection({required this.searches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.red,
                  border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
                ),
                child: const Icon(Icons.trending_up, size: 18, color: NeoBrutalismTheme.white),
              ),
              const SizedBox(width: 12),
              Text(
                'TRENDING SEARCH',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: searches.map((query) => _TrendingChip(label: query, onTap: () => onTap(query))).toList(),
          ),
          const SizedBox(height: 32),
          _InfoCard(),
        ],
      ),
    );
  }
}

class _TrendingChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _TrendingChip({required this.label, required this.onTap});

  @override
  State<_TrendingChip> createState() => _TrendingChipState();
}

class _TrendingChipState extends State<_TrendingChip> {
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
          14 + (_pressed ? 2 : 0),
          10 + (_pressed ? 2 : 0),
          14,
          10,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.yellow,
          border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 2, offsetY: 2)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 16, color: NeoBrutalismTheme.black),
            const SizedBox(width: 8),
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.blue,
        border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidth),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: NeoBrutalismTheme.white),
              const SizedBox(width: 8),
              Text(
                'TIPS PENCARIAN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Gunakan kata kunci spesifik\n'
            '• Coba kata kunci berbeda jika tidak menemukan\n'
            '• Pencarian tidak case-sensitive',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;
  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.red,
                border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidth),
                boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
              ),
              child: const Icon(Icons.search_off, size: 48, color: NeoBrutalismTheme.white),
            ),
            const SizedBox(height: 24),
            Text(
              'TIDAK DITEMUKAN',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "$query"',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.yellow,
                border: Border.all(color: NeoBrutalismTheme.black, width: 2),
              ),
              child: Text(
                'COBA KATA KUNCI LAIN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
