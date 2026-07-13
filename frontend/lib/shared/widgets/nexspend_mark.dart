import 'package:flutter/material.dart';

class NexSpendMark extends StatelessWidget {
  const NexSpendMark({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'NexSpend',
        style: Theme.of(
          context,
        ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}
