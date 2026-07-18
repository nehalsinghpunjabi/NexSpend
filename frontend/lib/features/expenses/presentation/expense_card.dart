import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/presentation/private_amount.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/entities/expense.dart';

class ExpenseCard extends ConsumerWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });
  final Expense expense;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final formatter = ref.watch(currencyFormatterProvider);
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: NexSpendRadii.large,
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: Semantics(
        button: true,
        label:
            '${expense.merchant}, ${expense.category}, ${formatter.formatOrMask(expense.amount, hidden: settings.privacyMode, decimals: 2)}',
        hint: 'Tap to edit. Swipe left to delete.',
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: NexSpendRadii.large,
            boxShadow: NexSpendEffects.cardShadow,
          ),
          child: Card(
            child: InkWell(
              borderRadius: NexSpendRadii.large,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Text(_initials(expense.merchant)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.merchant,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(
                                  expense.category,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                visualDensity: VisualDensity.compact,
                                side: BorderSide.none,
                              ),
                              Text(
                                expense.paymentMethod,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PrivateAmountText(
                          expense.amount,
                          decimals: 2,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatShortDate(expense.expenseDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String merchant) => merchant
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((word) => word.isEmpty ? '' : word[0])
      .join()
      .toUpperCase();
}
