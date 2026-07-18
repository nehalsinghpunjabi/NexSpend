import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import 'expense_query.dart';

class ExpenseFilterSheet extends ConsumerStatefulWidget {
  const ExpenseFilterSheet({
    super.key,
    required this.categories,
    required this.paymentMethods,
  });
  final Set<String> categories;
  final Set<String> paymentMethods;
  @override
  ConsumerState<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends ConsumerState<ExpenseFilterSheet> {
  late ExpenseFilter _filter;
  @override
  void initState() {
    super.initState();
    _filter = ref.read(expenseQueryProvider).filter;
  }

  Future<void> _customRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filter.customRange,
    );
    if (range != null) {
      setState(
        () => _filter = _filter.copyWith(
          period: ExpenseDatePeriod.custom,
          customRange: range,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: NexSpendRadii.pill,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      setState(() => _filter = const ExpenseFilter()),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Date', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseDatePeriod.values
                  .map(
                    (period) => ChoiceChip(
                      label: Text(_periodLabel(period)),
                      selected: _filter.period == period,
                      onSelected: (_) async {
                        if (period == ExpenseDatePeriod.custom) {
                          await _customRange();
                        } else {
                          setState(
                            () => _filter = _filter.copyWith(
                              period: period,
                              clearRange: true,
                            ),
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.categories
                  .map(
                    (item) => FilterChip(
                      label: Text(item),
                      selected: _filter.categories.contains(item),
                      onSelected: (selected) {
                        final values = {..._filter.categories};
                        selected ? values.add(item) : values.remove(item);
                        setState(
                          () => _filter = _filter.copyWith(categories: values),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment method',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.paymentMethods
                  .map(
                    (item) => FilterChip(
                      label: Text(item),
                      selected: _filter.paymentMethods.contains(item),
                      onSelected: (selected) {
                        final values = {..._filter.paymentMethods};
                        selected ? values.add(item) : values.remove(item);
                        setState(
                          () => _filter = _filter.copyWith(
                            paymentMethods: values,
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(expenseQueryProvider.notifier).setFilter(_filter);
                  Navigator.pop(context);
                },
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  String _periodLabel(ExpenseDatePeriod value) => switch (value) {
    ExpenseDatePeriod.all => 'All time',
    ExpenseDatePeriod.today => 'Today',
    ExpenseDatePeriod.thisWeek => 'This week',
    ExpenseDatePeriod.thisMonth => 'This month',
    ExpenseDatePeriod.lastMonth => 'Last month',
    ExpenseDatePeriod.custom => 'Custom range',
  };
}
