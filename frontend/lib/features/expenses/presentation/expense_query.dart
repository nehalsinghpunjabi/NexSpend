import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/expense.dart';
import 'expense_providers.dart';

enum ExpenseDatePeriod { all, today, thisWeek, thisMonth, lastMonth, custom }

enum ExpenseSort {
  newest,
  oldest,
  highestAmount,
  lowestAmount,
  merchantAscending,
  merchantDescending,
}

class ExpenseFilter {
  const ExpenseFilter({
    this.period = ExpenseDatePeriod.all,
    this.categories = const {},
    this.paymentMethods = const {},
    this.customRange,
  });

  final ExpenseDatePeriod period;
  final Set<String> categories;
  final Set<String> paymentMethods;
  final DateTimeRange? customRange;

  bool get isActive =>
      period != ExpenseDatePeriod.all ||
      categories.isNotEmpty ||
      paymentMethods.isNotEmpty;

  ExpenseFilter copyWith({
    ExpenseDatePeriod? period,
    Set<String>? categories,
    Set<String>? paymentMethods,
    DateTimeRange? customRange,
    bool clearRange = false,
  }) => ExpenseFilter(
    period: period ?? this.period,
    categories: categories ?? this.categories,
    paymentMethods: paymentMethods ?? this.paymentMethods,
    customRange: clearRange ? null : customRange ?? this.customRange,
  );
}

class ExpenseQuery {
  const ExpenseQuery({
    this.search = '',
    this.filter = const ExpenseFilter(),
    this.sort = ExpenseSort.newest,
  });
  final String search;
  final ExpenseFilter filter;
  final ExpenseSort sort;

  ExpenseQuery copyWith({
    String? search,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) => ExpenseQuery(
    search: search ?? this.search,
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
  );
}

final expenseQueryProvider =
    NotifierProvider<ExpenseQueryController, ExpenseQuery>(
      ExpenseQueryController.new,
    );

class ExpenseQueryController extends Notifier<ExpenseQuery> {
  @override
  ExpenseQuery build() => const ExpenseQuery();
  void setSearch(String value) => state = state.copyWith(search: value.trim());
  void setFilter(ExpenseFilter value) => state = state.copyWith(filter: value);
  void setSort(ExpenseSort value) => state = state.copyWith(sort: value);
  void clearFilters() => state = state.copyWith(filter: const ExpenseFilter());
}

final visibleExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  final query = ref.watch(expenseQueryProvider);
  final normalizedSearch = query.search.toLowerCase();
  final now = DateTime.now();
  final filtered = expenses.where((expense) {
    final matchesSearch =
        normalizedSearch.isEmpty ||
        '${expense.merchant} ${expense.category} ${expense.notes ?? ''}'
            .toLowerCase()
            .contains(normalizedSearch);
    final matchesCategory =
        query.filter.categories.isEmpty ||
        query.filter.categories.contains(expense.category);
    final matchesPayment =
        query.filter.paymentMethods.isEmpty ||
        query.filter.paymentMethods.contains(expense.paymentMethod);
    return matchesSearch &&
        matchesCategory &&
        matchesPayment &&
        _matchesPeriod(expense.expenseDate, query.filter, now);
  }).toList();
  filtered.sort(
    (a, b) => switch (query.sort) {
      ExpenseSort.newest => b.expenseDate.compareTo(a.expenseDate),
      ExpenseSort.oldest => a.expenseDate.compareTo(b.expenseDate),
      ExpenseSort.highestAmount => b.amount.compareTo(a.amount),
      ExpenseSort.lowestAmount => a.amount.compareTo(b.amount),
      ExpenseSort.merchantAscending => a.merchant.toLowerCase().compareTo(
        b.merchant.toLowerCase(),
      ),
      ExpenseSort.merchantDescending => b.merchant.toLowerCase().compareTo(
        a.merchant.toLowerCase(),
      ),
    },
  );
  return filtered;
});

bool _matchesPeriod(DateTime value, ExpenseFilter filter, DateTime now) {
  final date = DateUtils.dateOnly(value.toLocal());
  final today = DateUtils.dateOnly(now);
  switch (filter.period) {
    case ExpenseDatePeriod.all:
      return true;
    case ExpenseDatePeriod.today:
      return date == today;
    case ExpenseDatePeriod.thisWeek:
      final start = today.subtract(
        Duration(days: today.weekday - DateTime.monday),
      );
      return !date.isBefore(start) && !date.isAfter(today);
    case ExpenseDatePeriod.thisMonth:
      return date.year == today.year && date.month == today.month;
    case ExpenseDatePeriod.lastMonth:
      final last = DateTime(today.year, today.month - 1);
      return date.year == last.year && date.month == last.month;
    case ExpenseDatePeriod.custom:
      final range = filter.customRange;
      return range != null &&
          !date.isBefore(DateUtils.dateOnly(range.start)) &&
          !date.isAfter(DateUtils.dateOnly(range.end));
  }
}
