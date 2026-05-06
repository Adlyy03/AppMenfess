import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../core/neo_brutalism_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN — Neo-Brutalism Style
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final AppProvider provider;
  const SettingsScreen({super.key, required this.provider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = true;
  bool _soundEnabled = false;

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => _LogoutDialog(),
    );
    if (confirm == true && mounted) {
      await widget.provider.signOut();
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('AKUN'),
                        const SizedBox(height: 12),
                        _buildAccountCard(),
                        const SizedBox(height: 24),
                        _sectionLabel('NOTIFIKASI'),
                        const SizedBox(height: 12),
                        _buildNotifCard(),
                        const SizedBox(height: 24),
                        _sectionLabel('TENTANG'),
                        const SizedBox(height: 12),
                        _buildAboutCard(),
                        const SizedBox(height: 32),
                        _buildLogoutButton(),
                        const SizedBox(height: 20),
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
          _BackButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: 12),
          Text(
            'PENGATURAN',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.blue,
        border: Border.all(color: NeoBrutalismTheme.black, width: 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final userId = widget.provider.userId ?? '';
    final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
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
          _SettingsTile(
            icon: Icons.person,
            title: 'ID PENGGUNA',
            subtitle: '$shortId...',
            showArrow: false,
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.verified_user,
            title: 'STATUS AKUN',
            subtitle: 'Terverifikasi',
            showArrow: false,
            trailingWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.blue,
                border: Border.all(color: NeoBrutalismTheme.black, width: 2),
              ),
              child: Text(
                'AKTIF',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.lock,
            title: 'PRIVASI',
            subtitle: 'Identitas tersembunyi',
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard() {
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
          _SettingsTile(
            icon: Icons.notifications,
            title: 'NOTIFIKASI',
            subtitle: 'Terima notifikasi like & komentar',
            showArrow: false,
            trailingWidget: _BrutalSwitch(
              value: _notifEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _notifEnabled = v);
              },
            ),
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.volume_up,
            title: 'SUARA',
            subtitle: 'Suara saat ada notifikasi',
            showArrow: false,
            trailingWidget: _BrutalSwitch(
              value: _soundEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _soundEnabled = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
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
          _SettingsTile(
            icon: Icons.info,
            title: 'VERSI APLIKASI',
            subtitle: '1.0.0',
            showArrow: false,
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.shield,
            title: 'KEBIJAKAN PRIVASI',
            subtitle: 'Baca kebijakan privasi kami',
            onTap: () {},
          ),
          _Divider(),
          _SettingsTile(
            icon: Icons.help,
            title: 'BANTUAN',
            subtitle: 'Hubungi tim support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return _LogoutButton(onTap: _confirmLogout);
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showArrow;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showArrow = true,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NeoBrutalismTheme.yellow,
                  border: Border.all(color: NeoBrutalismTheme.black, width: 2),
                ),
                child: Icon(icon, size: 20, color: NeoBrutalismTheme.black),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget!,
              if (showArrow && trailingWidget == null)
                const Icon(Icons.chevron_right, size: 24, color: NeoBrutalismTheme.black),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrutalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BrutalSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? NeoBrutalismTheme.blue : NeoBrutalismTheme.white,
          border: Border.all(color: NeoBrutalismTheme.black, width: 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value ? NeoBrutalismTheme.yellow : NeoBrutalismTheme.black,
              border: Border.all(color: NeoBrutalismTheme.black, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
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
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.only(
          top: _pressed ? 4 : 0,
          left: _pressed ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: NeoBrutalismTheme.red,
          border: Border.all(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow()],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 22, color: NeoBrutalismTheme.white),
            const SizedBox(width: 12),
            Text(
              'KELUAR DARI AKUN',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.white,
                letterSpacing: 1.0,
              ),
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
              child: const Icon(Icons.logout, size: 32, color: NeoBrutalismTheme.white),
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
          border: Border.all(color: NeoBrutalismTheme.black, width: NeoBrutalismTheme.borderWidthThin),
          boxShadow: _pressed ? [] : [NeoBrutalismTheme.hardShadow(offsetX: 3, offsetY: 3)],
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
