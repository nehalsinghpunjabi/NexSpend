import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/repositories/supabase_profile_repository.dart';
import 'onboarding_providers.dart';

class PersonaPage extends ConsumerWidget {
  const PersonaPage({super.key});

  static const _personas = [
    ('\u{1F393}', 'Student'),
    ('\u{1F4BC}', 'Salaried'),
    ('\u{1F680}', 'Self-employed'),
    ('\u{1F474}', 'Retired'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPersonaProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tell us about yourself.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'This helps NexSpend make future guidance more relevant.',
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.builder(
                itemCount: _personas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (_, index) {
                  final item = _personas[index];
                  final active = selected == item.$2;
                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => ref
                        .read(selectedPersonaProvider.notifier)
                        .select(item.$2),
                    child: Card(
                      color: active
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1, style: const TextStyle(fontSize: 30)),
                            const Spacer(),
                            Text(
                              item.$2,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () async {
                      if (user == null) {
                        context.go('/auth');
                        return;
                      }
                      await ref
                          .read(profileRepositoryProvider)
                          .savePersona(userId: user.id, persona: selected);
                      ref.invalidate(currentPersonaProvider);
                      if (context.mounted) context.go('/home');
                    },
              child: Text(user == null ? 'Continue' : 'Save and continue'),
            ),
          ],
        ),
      ),
    );
  }
}
