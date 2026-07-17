import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/theme/design_tokens.dart';
import 'auth_providers.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            const _PreviewCards(),
            const Spacer(),
            Text(
              'Talk to\nyour money.',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 32, height: 1.15),
            ),
            const SizedBox(height: 12),
            Text(
              'NexSpend uses AI to understand your spending habits and help you make smarter financial decisions.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(54),
              ),
              icon: const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              label: const Text('Continue with Google'),
              onPressed: () => _signIn(context, ref),
            ),
            const SizedBox(height: 14),
            Text(
              'By continuing you agree to our Terms & Privacy Policy.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    ),
  );

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add Supabase settings to run Google sign-in.'),
        ),
      );
      return;
    }
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
      }
    }
  }
}

class _PreviewCards extends StatelessWidget {
  const _PreviewCards();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.trending_up_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'July Spending',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('₹2,847 of ₹3,500 budget'),
                    ],
                  ),
                ),
                Text(
                  '↘ 19%',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: .16),
              child: const Icon(Icons.restaurant, color: Colors.orange),
            ),
            title: const Text('Nobu Restaurant'),
            subtitle: const Text('Food & Dining · Jul 9'),
            trailing: const Text(
              '-₹234.50',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: .45),
            borderRadius: NexSpendRadii.medium,
            border: Border.all(color: scheme.primary.withValues(alpha: .45)),
          ),
          child: const Text(
            '✧  AI Insight · You can save about ₹180/mo by reducing dining out. You’re on track to finish the month under budget!',
          ),
        ),
      ],
    );
  }
}
