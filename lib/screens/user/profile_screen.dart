import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../core/neo_brutalism_theme.dart';
import 'settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final AppProvider provider;
  const ProfileScreen({super.key, required this.provider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: NeoBrutalismTheme.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAvatarCard(),
                        const SizedBox(height: 20),
                        _buildStatsRow(),
                        const SizedBox(height: 20),
                        _buildInfoCard(),
                        const SizedBox(height: 20),
                        _buildMenuCard(),
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
              Icons.person,
              size: 24,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PROFIL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          _SettingsButton(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(provider: widget.provider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard() {
    final userId = widget.provider.userId ?? '';
    final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.blue,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.yellow,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidth,
              ),
              boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 4, offsetY: 4)],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: NeoBrutalismTheme.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'PENGGUNA ANONIM',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.black,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidthThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fingerprint,
                  size: 16,
                  color: NeoBrutalismTheme.yellow,
                ),
                const SizedBox(width: 8),
                Text(
                  'ID: $shortId...',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.yellow,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.send,
                label: 'MENFESS',
                value: '${widget.provider.userPostCount}',
                color: NeoBrutalismTheme.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.favorite,
                label: 'LIKES',
                value: '${widget.provider.userTotalLikes}',
                color: NeoBrutalismTheme.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.today,
                label: 'HARI INI',
                value: '${widget.provider.todayPostCount}/5',
                color: NeoBrutalismTheme.yellow,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.verified_user,
            label: 'STATUS',
            value: 'TERVERIFIKASI',
            valueColor: NeoBrutalismTheme.blue,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.lock,
            label: 'PRIVASI',
            value: 'TERSEMBUNYI',
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.post_add,
            label: 'BATAS POST',
            value: '5 / HARI',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.settings,
            label: 'PENGATURAN',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(provider: widget.provider),
                ),
              );
            },
          ),
          _Divider(),
          _MenuTile(
            icon: Icons.logout,
            label: 'KELUAR',
            color: NeoBrutalismTheme.red,
            onTap: () async {
              HapticFeedback.mediumImpact();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => _LogoutDialog(),
              );
              if (confirm == true && mounted) {
                await widget.provider.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SettingsButton({required this.onTap});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
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
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidthThin,
          ),
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: const Icon(
          Icons.settings,
          size: 22,
          color: NeoBrutalismTheme.black,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28,
            color: color == NeoBrutalismTheme.yellow
                ? NeoBrutalismTheme.black
                : NeoBrutalismTheme.white,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color == NeoBrutalismTheme.yellow
                  ? NeoBrutalismTheme.black
                  : NeoBrutalismTheme.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color == NeoBrutalismTheme.yellow
                  ? NeoBrutalismTheme.black
                  : NeoBrutalismTheme.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.yellow,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidthThin,
              ),
            ),
            child: Icon(icon, size: 20, color: NeoBrutalismTheme.black),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: NeoBrutalismTheme.black,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor ?? NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: NeoBrutalismTheme.black,
    );
  }
}

class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? NeoBrutalismTheme.black;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        color: _pressed
            ? NeoBrutalismTheme.black.withOpacity(0.05)
            : Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c == NeoBrutalismTheme.red
                    ? NeoBrutalismTheme.red
                    : NeoBrutalismTheme.blue,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidthThin,
                ),
              ),
              child: Icon(widget.icon, size: 20, color: NeoBrutalismTheme.white),
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: c,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: c,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NeoBrutalismTheme.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.white,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: [NeoBrutalismTheme.hardShadow(offsetX: 6, offsetY: 6)],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.red,
                border: Border.all(
                  color: NeoBrutalismTheme.black,
                  width: NeoBrutalismTheme.borderWidth,
                ),
              ),
              child: const Icon(
                Icons.logout,
                size: 32,
                color: NeoBrutalismTheme.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'KELUAR DARI AKUN?',
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
              'Kamu akan keluar dari akun ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'BATAL',
                    bgColor: NeoBrutalismTheme.white,
                    textColor: NeoBrutalismTheme.black,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'KELUAR',
                    bgColor: NeoBrutalismTheme.red,
                    textColor: NeoBrutalismTheme.white,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
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
        height: 50,
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
          boxShadow: _pressed
              ? []
              : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: widget.textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
