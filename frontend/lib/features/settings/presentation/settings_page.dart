import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import 'settings_providers.dart';
import 'settings_detail_pages.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 112),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Personalise your NexSpend experience.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: NexSpendSpace.lg),
          _ProfileCard(scheme: scheme),
          const SizedBox(height: 28),
          _SettingsSection(
            title: 'Account & preferences',
            children: [
              _ActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Manage accounts',
                detail: 'Cards, banks & wallets',
                onTap: () => _push(context, const ManageAccountsPage()),
              ),
              _ActionTile(
                icon: Icons.currency_rupee,
                title: 'Currency',
                detail: _currencyLabel(settings.currency),
                onTap: () =>
                    _pickCurrency(context, controller, settings.currency),
              ),
              _ActionTile(
                icon: Icons.dark_mode_outlined,
                title: 'Appearance',
                detail: _themeLabel(settings.theme),
                onTap: () => _pickTheme(context, controller, settings.theme),
              ),
              _SwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                detail: 'Spending reminders and updates',
                value: settings.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
              ),
              _ActionTile(
                icon: Icons.language_rounded,
                title: 'Language',
                detail: 'English',
                onTap: () => _showInfo(
                  context,
                  'Language',
                  'English is currently the available language.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsSection(
            title: 'Privacy & security',
            children: [
              _ActionTile(
                icon: Icons.security_outlined,
                title: 'Security',
                detail: 'Protect your NexSpend account',
                onTap: () => _push(context, const SecurityPage()),
              ),
              _ActionTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric authentication',
                detail: 'Secure access on this device',
                onTap: () => _push(context, const SecurityPage()),
              ),
              _ActionTile(
                icon: Icons.visibility_off_outlined,
                title: 'Privacy mode',
                detail: 'Hide sensitive values on screen',
                onTap: () => _push(context, const SecurityPage()),
              ),
              _ActionTile(
                icon: Icons.pin_outlined,
                title: 'Change PIN',
                detail: 'Add an extra layer of protection',
                onTap: () => _push(context, const SecurityPage()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsSection(
            title: 'Support',
            children: [
              _ActionTile(
                icon: Icons.info_outline_rounded,
                title: 'About NexSpend',
                detail: 'Version and legal information',
                onTap: () => _push(context, const AboutPage()),
              ),
              _ActionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                detail: 'Get help with your account',
                onTap: () => _push(context, const HelpPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  static void _showInfo(BuildContext context, String title, String message) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

  static String _currencyLabel(String currency) => switch (currency) {
    'USD' => 'US dollar (USD)',
    'EUR' => 'Euro (EUR)',
    _ => 'Indian rupee (INR)',
  };
  static String _themeLabel(AppThemePreference theme) => switch (theme) {
    AppThemePreference.light => 'Light',
    AppThemePreference.dark => 'Dark',
    AppThemePreference.system => 'System default',
  };

  Future<void> _pickCurrency(
    BuildContext context,
    SettingsController controller,
    String selected,
  ) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet(
        title: 'Currency',
        values: const {
          'INR': 'Indian rupee (INR)',
          'USD': 'US dollar (USD)',
          'EUR': 'Euro (EUR)',
        },
        selected: selected,
      ),
    );
    if (value != null) await controller.setCurrency(value);
  }

  Future<void> _pickTheme(
    BuildContext context,
    SettingsController controller,
    AppThemePreference selected,
  ) async {
    final value = await showModalBottomSheet<AppThemePreference>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet(
        title: 'Appearance',
        values: const {
          AppThemePreference.system: 'System default',
          AppThemePreference.light: 'Light',
          AppThemePreference.dark: 'Dark',
        },
        selected: selected,
      ),
    );
    if (value != null) await controller.setTheme(value);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: NexSpendGradients.hero,
      borderRadius: NexSpendRadii.large,
      boxShadow: NexSpendEffects.cardShadow,
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: scheme.surface.withValues(alpha: .9),
          child: Icon(Icons.person_outline, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NexSpend member',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Your financial workspace',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.verified_rounded, color: scheme.onPrimary),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    onTap: onTap,
    leading: _TileIcon(icon),
    title: Text(title),
    subtitle: Text(detail),
    trailing: Icon(
      Icons.chevron_right_rounded,
      color: Theme.of(context).colorScheme.outline,
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title, detail;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    secondary: _TileIcon(icon),
    title: Text(title),
    subtitle: Text(detail),
    value: value,
    onChanged: onChanged,
  );
}

class _TileIcon extends StatelessWidget {
  const _TileIcon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: NexSpendRadii.small,
      ),
      child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
    );
  }
}

class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.values,
    required this.selected,
  });
  final String title;
  final Map<T, String> values;
  final T selected;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final entry in values.entries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                entry.key == selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
              ),
              title: Text(entry.value),
              onTap: () => Navigator.pop(context, entry.key),
            ),
        ],
      ),
    ),
  );
}
