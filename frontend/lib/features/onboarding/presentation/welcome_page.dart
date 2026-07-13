import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/nexspend_mark.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const NexSpendMark(),
            const SizedBox(height: 28),
            Text(
              'Your AI Financial Copilot',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'A clearer, calmer way to understand your money.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/persona'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    ),
  );
}
