import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';
import '../../models/menfess_model.dart';
import '../../widgets/user/menfess_card.dart';
import '../../widgets/user/menfess_skeleton.dart';
import '../../core/neo_brutalism_theme.dart';
import 'detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOOKMARK SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class BookmarkScreen extends StatefulWidget {
  final AppProvider provider;
  const BookmarkScreen({super.key, required this.provider});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  bool _isLoading = true;
  List<MenfessModel> _bookmarkedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final ids = await widget.provider.getAllBookmarkedIds();
      if (ids.isNotEmpty) {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('menfess')
            .select()
            .inFilter('id', ids)
            .order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _bookmarkedPosts = (response as List)
                .map((e) => MenfessModel.fromMap(e as Map<String, dynamic>))
                .toList();
          });
        }
      } else {
        if (mounted) setState(() => _bookmarkedPosts = []);
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: _buildContent()),
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
              Icons.bookmark,
              size: 22,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TERSIMPAN',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          if (_bookmarkedPosts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.black,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: 2,
                ),
              ),
              child: Text(
                '${_bookmarkedPosts.length}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.yellow,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        itemCount: 4,
        itemBuilder: (_, a) => const MenfessSkeleton(),
      );
    }

    if (_bookmarkedPosts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookmarks,
        color: NeoBrutalismTheme.blue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _EmptyState(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      color: NeoBrutalismTheme.blue,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: _bookmarkedPosts.length,
        itemBuilder: (context, i) => MenfessCard(
          menfess: _bookmarkedPosts[i],
          provider: widget.provider,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  menfess: _bookmarkedPosts[i],
                  provider: widget.provider,
                ),
              ),
            );
          },
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
              Icons.bookmark,
              size: 48,
              color: NeoBrutalismTheme.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BELUM ADA YANG\nTERSIMPAN',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              height: 1.2,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap ikon bookmark di menfess\nyang ingin kamu simpan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.black,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
