import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          Container(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
          ),
          const SizedBox(height: 28),
          const _SettingsSection(
            title: 'Preferences',
            entries: [
              _SettingsEntry(
                Icons.currency_rupee,
                'Currency',
                'Indian rupee (INR)',
              ),
              _SettingsEntry(
                Icons.notifications_none_rounded,
                'Notifications',
                'Stay informed about your spending',
              ),
              _SettingsEntry(
                Icons.dark_mode_outlined,
                'Appearance',
                'System default',
              ),
              _SettingsEntry(Icons.language_rounded, 'Language', 'English'),
            ],
          ),
          const SizedBox(height: 22),
          const _SettingsSection(
            title: 'Privacy & security',
            entries: [
              _SettingsEntry(
                Icons.fingerprint_rounded,
                'Biometric authentication',
                'Secure access on this device',
              ),
              _SettingsEntry(
                Icons.visibility_off_outlined,
                'Privacy mode',
                'Hide sensitive values on screen',
              ),
              _SettingsEntry(
                Icons.pin_outlined,
                'Change PIN',
                'Add an extra layer of protection',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsEntry {
  const _SettingsEntry(this.icon, this.title, this.detail);
  final IconData icon;
  final String title;
  final String detail;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.entries});
  final String title;
  final List<_SettingsEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: NexSpendRadii.small,
                    ),
                    child: Icon(
                      entries[index].icon,
                      color: scheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(entries[index].title),
                  subtitle: Text(entries[index].detail),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.outline,
                  ),
                ),
                if (index < entries.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: scheme.outlineVariant.withValues(alpha: .5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
