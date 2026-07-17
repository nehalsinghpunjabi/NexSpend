import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_providers.dart';

class ManageAccountsPage extends ConsumerWidget {
  const ManageAccountsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return _SettingsScaffold(
      title: 'Manage accounts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred payment methods',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('NexSpend does not collect card or bank details.'),
          const SizedBox(height: 18),
          _MethodSwitch(
            icon: Icons.credit_card_outlined,
            title: 'Debit Card',
            detail: 'Use for spending insights only',
            value: settings.debitCardEnabled,
            onChanged: controller.setDebitCardEnabled,
          ),
          _MethodSwitch(
            icon: Icons.credit_card_rounded,
            title: 'Credit Card',
            detail: 'Use for spending insights only',
            value: settings.creditCardEnabled,
            onChanged: controller.setCreditCardEnabled,
          ),
          _MethodSwitch(
            icon: Icons.account_balance_wallet_outlined,
            title: 'UPI',
            detail: settings.upiId ?? 'Optional UPI ID',
            value: settings.upiEnabled,
            onChanged: (value) => controller.setUpi(enabled: value),
          ),
          const SizedBox(height: 18),
          if (settings.upiId == null)
            _EmptyPaymentState(onAdd: () => _editUpi(context, controller))
          else
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _editUpi(context, controller, settings.upiId),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit UPI ID'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.setUpi(enabled: false, clearId: true),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove UPI ID'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _editUpi(
    BuildContext context,
    SettingsController controller, [
    String? current,
  ]) async {
    final input = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(current == null ? 'Add UPI ID' : 'Edit UPI ID'),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'user@oksbi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    input.dispose();
    if (value != null && value.isNotEmpty) {
      await controller.setUpi(enabled: true, id: value);
    }
  }
}

class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return _SettingsScaffold(
      title: 'Security',
      child: Column(
        children: [
          _MethodSwitch(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric authentication',
            detail: 'Biometric support coming soon.',
            value: settings.biometricEnabled,
            onChanged: (enabled) async {
              await controller.setBiometricEnabled(enabled);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric support coming soon.'),
                  ),
                );
              }
            },
          ),
          _MethodSwitch(
            icon: Icons.visibility_off_outlined,
            title: 'Privacy mode',
            detail: 'Hide money values throughout NexSpend',
            value: settings.privacyMode,
            onChanged: controller.setPrivacyMode,
          ),
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('Change PIN'),
            subtitle: const Text(
              'PIN protection is planned for a future update.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Change PIN'),
                content: const Text(
                  'PIN protection is planned for a future update.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => const _SettingsScaffold(
    title: 'About NexSpend',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NexSpend',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        Text('Version 1.0.0 · Build 1'),
        SizedBox(height: 16),
        Text(
          'Your AI-native financial copilot for clearer everyday spending decisions.',
        ),
      ],
    ),
  );
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => _SettingsScaffold(
    title: 'Help & support',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently asked questions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          'How does NexSpend use my data?\nYour expense data powers your on-device presentation and financial insights.',
        ),
        const SizedBox(height: 12),
        const Text(
          'How can I edit an expense?\nTap any expense card to edit it.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _info(context, 'Contact Support'),
          icon: const Icon(Icons.support_agent_outlined),
          label: const Text('Contact Support'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _info(context, 'Report Issue'),
          icon: const Icon(Icons.bug_report_outlined),
          label: const Text('Report Issue'),
        ),
      ],
    ),
  );
  static void _info(BuildContext context, String title) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Support messaging will be available in a future update.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: ListView(padding: const EdgeInsets.all(24), children: [child]),
    ),
  );
}

class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({
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
    contentPadding: EdgeInsets.zero,
    secondary: Icon(icon),
    title: Text(title),
    subtitle: Text(detail),
    value: value,
    onChanged: onChanged,
  );
}

class _EmptyPaymentState extends StatelessWidget {
  const _EmptyPaymentState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 42),
        const SizedBox(height: 10),
        const Text(
          'No payment methods configured.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'This helps NexSpend personalize spending insights.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add UPI ID'),
        ),
      ],
    ),
  );
}
