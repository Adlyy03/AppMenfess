import 'package:flutter/material.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  final AppProvider provider;
  const ProfileScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = provider.userId ?? '';
    final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // ── Name / ID ────────────────────────────────────────────
                  Text(
                    'Pengguna Anonim',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: $shortId...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Stats row ────────────────────────────────────────────
                  _StatsRow(provider: provider),
                  const SizedBox(height: 24),

                  // ── Info card ────────────────────────────────────────────
                  _InfoCard(theme: theme),
                  const SizedBox(height: 24),

                  // ── Logout button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await _confirmLogout(context);
                        if (confirm == true) {
                          await provider.signOut();
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side:
                            BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ThemeData theme;
  const _InfoCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: 'Terverifikasi',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.lock_outline_rounded,
            label: 'Privasi',
            value: 'Identitas tersembunyi',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.post_add_rounded,
            label: 'Batas post',
            value: '3 menfess / hari',
            theme: theme,
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
  final ThemeData theme;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return Row(
          children: [
            _StatItem(
              label: 'Menfess',
              value: '${provider.userPostCount}',
              icon: Icons.send_rounded,
              theme: theme,
            ),
            const SizedBox(width: 12),
            _StatItem(
              label: 'Total Like',
              value: '${provider.userTotalLikes}',
              icon: Icons.favorite_rounded,
              theme: theme,
              iconColor: theme.colorScheme.error,
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final Color? iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
