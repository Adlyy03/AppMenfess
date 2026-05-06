import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/notification_model.dart';
import '../../core/neo_brutalism_theme.dart';

class NotificationScreen extends StatefulWidget {
  final AppProvider provider;
  const NotificationScreen({super.key, required this.provider});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.markNotificationsAsRead();
    });
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
                  child: ListenableBuilder(
                    listenable: widget.provider,
                    builder: (context, _) => _buildContent(),
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
              Icons.notifications_rounded,
              size: 22,
              color: NeoBrutalismTheme.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'NOTIFIKASI',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          if ((widget.provider.notifications ?? []).isNotEmpty)
            _RefreshButton(
              onTap: () => widget.provider.fetchNotifications(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final notifs = widget.provider.notifications ?? [];

    if (widget.provider.notifLoading && notifs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: NeoBrutalismTheme.black,
          strokeWidth: 3,
        ),
      );
    }

    if (notifs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => widget.provider.fetchNotifications(),
      color: NeoBrutalismTheme.black,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.length,
        itemBuilder: (context, index) {
          return _NotificationTile(notification: notifs[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              Icons.notifications_none_rounded,
              size: 48,
              color: NeoBrutalismTheme.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'BELUM ADA NOTIFIKASI',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Aktivitas seperti like, komentar,\ndan bookmark akan muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RefreshButton({required this.onTap});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton> {
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
        child: const Icon(
          Icons.refresh_rounded,
          size: 22,
          color: NeoBrutalismTheme.yellow,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconBgColor;

    switch (notification.type) {
      case 'like':
        icon = Icons.favorite_rounded;
        iconBgColor = NeoBrutalismTheme.red;
        break;
      case 'comment':
        icon = Icons.chat_bubble_rounded;
        iconBgColor = NeoBrutalismTheme.blue;
        break;
      case 'bookmark':
        icon = Icons.bookmark_rounded;
        iconBgColor = NeoBrutalismTheme.yellow;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconBgColor = NeoBrutalismTheme.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalismTheme.white,
        border: Border.all(
          color: NeoBrutalismTheme.black,
          width: NeoBrutalismTheme.borderWidth,
        ),
        boxShadow: [NeoBrutalismTheme.hardShadow()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              border: Border.all(
                color: NeoBrutalismTheme.black,
                width: NeoBrutalismTheme.borderWidthThin,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: notification.type == 'bookmark' 
                  ? NeoBrutalismTheme.black 
                  : NeoBrutalismTheme.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.black,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoBrutalismTheme.yellow,
                    border: Border.all(
                      color: NeoBrutalismTheme.black,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd MMM, HH:mm').format(notification.createdAt).toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.black,
                      letterSpacing: 0.5,
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
