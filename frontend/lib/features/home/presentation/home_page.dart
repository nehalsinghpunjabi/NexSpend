import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Good Evening 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to NexSpend.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Center(
              child: Text(
                'No expenses yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
  );
}
