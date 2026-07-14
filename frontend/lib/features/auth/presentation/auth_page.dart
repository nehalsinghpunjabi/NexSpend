import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_config.dart';
import '../../../shared/widgets/nexspend_mark.dart';
import 'auth_providers.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const NexSpendMark(),
            const SizedBox(height: 32),
            Text(
              'Continue with Google',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Securely sign in to save your NexSpend data.'),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: const Text('Continue with Google'),
              onPressed: () async {
                if (!SupabaseConfig.isConfigured) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Add Supabase settings to run Google sign-in.',
                      ),
                    ),
                  );
                  return;
                }
                try {
                  await ref.read(authRepositoryProvider).signInWithGoogle();
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign-in failed: $error')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
