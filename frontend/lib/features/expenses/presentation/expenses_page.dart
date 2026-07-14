import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/expense.dart';
import 'add_expense_sheet.dart';
import 'expense_card.dart';
import 'expense_empty_state.dart';
import 'expense_filter_sheet.dart';
import 'expense_providers.dart';
import 'expense_query.dart';
import 'expense_search_field.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expensesProvider);
    final query = ref.watch(expenseQueryProvider);
    final visible = ref.watch(visibleExpensesProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expenses', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Search, filter, and manage every transaction.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const ExpenseSearchField(),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: allExpenses.value == null
                      ? null
                      : () => _showFilters(context, allExpenses.value!),
                  icon: const Icon(Icons.tune),
                  label: Text(
                    query.filter.isActive ? 'Filters active' : 'Filters',
                  ),
                ),
                const Spacer(),
                PopupMenuButton<ExpenseSort>(
                  onSelected: (sort) =>
                      ref.read(expenseQueryProvider.notifier).setSort(sort),
                  itemBuilder: (_) => ExpenseSort.values
                      .map(
                        (sort) => PopupMenuItem<ExpenseSort>(
                          value: sort,
                          child: Row(
                            children: [
                              if (sort == query.sort)
                                const Icon(Icons.check, size: 18)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(_sortLabel(sort)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.sort),
                    label: Text(_sortLabel(query.sort)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allExpenses.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Could not load expenses: $error')),
                data: (items) {
                  if (items.isEmpty) {
                    return const ExpenseEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No expenses yet',
                      message:
                          'Add your first expense to start tracking your spending.',
                    );
                  }
                  if (visible.isEmpty) {
                    return ExpenseEmptyState(
                      icon: query.search.isNotEmpty
                          ? Icons.search_off_outlined
                          : Icons.filter_alt_off_outlined,
                      title: query.search.isNotEmpty
                          ? 'No search results'
                          : query.filter.period == ExpenseDatePeriod.thisMonth
                          ? 'No expenses this month'
                          : 'No matching expenses',
                      message: query.search.isNotEmpty
                          ? 'Try another merchant, category, or note.'
                          : 'Adjust or clear your filters to see more expenses.',
                    );
                  }
                  return ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final expense = visible[index];
                      return ExpenseCard(
                        expense: expense,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => AddExpenseSheet(expense: expense),
                        ),
                        onDelete: () => _deleteExpense(
                          context: context,
                          ref: ref,
                          expense: expense,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context, List<Expense> items) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ExpenseFilterSheet(
          categories: items.map((expense) => expense.category).toSet(),
          paymentMethods: items.map((expense) => expense.paymentMethod).toSet(),
        ),
      );

  Future<bool> _deleteExpense({
    required BuildContext context,
    required WidgetRef ref,
    required Expense expense,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete expense?'),
        content: Text('Remove ${expense.merchant} from your expenses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return false;
    }
    try {
      await ref.read(expenseActionsProvider).deleteExpense(expense);
      if (!context.mounted) {
        return true;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Expense deleted.'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async =>
                  ref.read(expenseActionsProvider).restoreExpense(expense),
            ),
          ),
        );
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete expense: $error')),
        );
      }
      return false;
    }
  }

  String _sortLabel(ExpenseSort value) => switch (value) {
    ExpenseSort.newest => 'Newest',
    ExpenseSort.oldest => 'Oldest',
    ExpenseSort.highestAmount => 'Highest amount',
    ExpenseSort.lowestAmount => 'Lowest amount',
    ExpenseSort.merchantAscending => 'Merchant A-Z',
    ExpenseSort.merchantDescending => 'Merchant Z-A',
  };
}
