import 'dart:math';

import '../../../expenses/domain/entities/expense.dart';

class FinancialInsight {
  const FinancialInsight({
    required this.title,
    required this.detail,
    required this.icon,
  });
  final String title;
  final String detail;
  final String icon;
}

class FinancialSnapshot {
  const FinancialSnapshot({
    required this.monthlyTotal,
    required this.transactionCount,
    required this.dailyAverage,
    required this.largestExpense,
    required this.largestCategory,
    required this.categories,
    required this.merchants,
    required this.previousMonthTotal,
    required this.monthOverMonthPercent,
    required this.spendingVelocity,
    required this.healthScore,
    required this.healthExplanation,
    required this.insights,
  });

  final double monthlyTotal;
  final int transactionCount;
  final double dailyAverage;
  final Expense? largestExpense;
  final String? largestCategory;
  final Map<String, double> categories;
  final Map<String, MerchantMetric> merchants;
  final double previousMonthTotal;
  final double? monthOverMonthPercent;
  final double spendingVelocity;
  final int healthScore;
  final String healthExplanation;
  final List<FinancialInsight> insights;

  bool get hasData => transactionCount > 0;

  Map<String, dynamic> toAiPayload() => {
    'monthly_summary': {
      'total_spent': monthlyTotal,
      'total_transactions': transactionCount,
      'daily_average': dailyAverage,
      'largest_expense': largestExpense == null
          ? null
          : {
              'merchant': largestExpense!.merchant,
              'amount': largestExpense!.amount,
            },
      'largest_category': largestCategory,
    },
    'category_breakdown': categories.entries
        .map(
          (entry) => {
            'category': entry.key,
            'total': entry.value,
            'percentage': monthlyTotal == 0
                ? 0
                : entry.value / monthlyTotal * 100,
          },
        )
        .toList(),
    'merchant_analysis': merchants.entries
        .map(
          (entry) => {
            'merchant': entry.key,
            'total': entry.value.total,
            'transactions': entry.value.count,
          },
        )
        .toList(),
    'budget_analysis': {
      'budget_configured': false,
      'spent': monthlyTotal,
      'remaining_budget': null,
      'budget_utilization': null,
      'overspent_categories': <String>[],
    },
    'trend_analysis': {
      'current_month': monthlyTotal,
      'previous_month': previousMonthTotal,
      'month_over_month_percent': monthOverMonthPercent,
      'spending_velocity_per_day': spendingVelocity,
    },
    'financial_health': {
      'score': healthScore,
      'explanation': healthExplanation,
      'savings_rate_available': false,
    },
  };
}

class MerchantMetric {
  const MerchantMetric(this.total, this.count);
  final double total;
  final int count;
}

abstract final class FinancialAnalytics {
  static FinancialSnapshot build(List<Expense> expenses, {DateTime? now}) {
    final date = now ?? DateTime.now();
    final thisMonth = expenses
        .where(
          (expense) =>
              expense.expenseDate.year == date.year &&
              expense.expenseDate.month == date.month,
        )
        .toList();
    final previousAnchor = DateTime(date.year, date.month - 1);
    final previous = expenses
        .where(
          (expense) =>
              expense.expenseDate.year == previousAnchor.year &&
              expense.expenseDate.month == previousAnchor.month,
        )
        .toList();
    final total = thisMonth.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final previousTotal = previous.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final categories = <String, double>{};
    final merchantTotals = <String, MerchantMetric>{};
    for (final expense in thisMonth) {
      categories.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      final metric = merchantTotals[expense.merchant];
      merchantTotals[expense.merchant] = MerchantMetric(
        (metric?.total ?? 0) + expense.amount,
        (metric?.count ?? 0) + 1,
      );
    }
    final orderedCategories = Map<String, double>.fromEntries(
      categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    final orderedMerchants = Map<String, MerchantMetric>.fromEntries(
      merchantTotals.entries.toList()
        ..sort((a, b) => b.value.total.compareTo(a.value.total)),
    );
    final largest = thisMonth.isEmpty
        ? null
        : thisMonth.reduce((a, b) => a.amount >= b.amount ? a : b);
    final percent = previousTotal == 0
        ? null
        : (total - previousTotal) / previousTotal * 100;
    final consistency =
        thisMonth
            .map(
              (expense) =>
                  '${expense.expenseDate.year}-${expense.expenseDate.month}-${expense.expenseDate.day}',
            )
            .toSet()
            .length /
        max(date.day, 1);
    final diversity = min(orderedCategories.length / 5, 1.0);
    final score = thisMonth.isEmpty
        ? 50
        : (50 + consistency * 25 + diversity * 15).round().clamp(0, 100);
    final insights = _insights(
      total,
      previousTotal,
      percent,
      orderedCategories,
      date,
    );
    return FinancialSnapshot(
      monthlyTotal: total,
      transactionCount: thisMonth.length,
      dailyAverage: total / max(date.day, 1),
      largestExpense: largest,
      largestCategory: orderedCategories.isEmpty
          ? null
          : orderedCategories.keys.first,
      categories: orderedCategories,
      merchants: orderedMerchants,
      previousMonthTotal: previousTotal,
      monthOverMonthPercent: percent,
      spendingVelocity: total / max(date.day, 1),
      healthScore: score.toInt(),
      healthExplanation: thisMonth.isEmpty
          ? 'Add expenses to build a personalised health view.'
          : 'Your score reflects spending consistency and category diversity. Set a budget to include budget adherence.',
      insights: insights,
    );
  }

  static List<FinancialInsight> _insights(
    double total,
    double previous,
    double? percent,
    Map<String, double> categories,
    DateTime date,
  ) {
    if (total == 0) {
      return const [
        FinancialInsight(
          title: 'Ready when you are',
          detail: 'Add an expense to unlock data-backed insights.',
          icon: 'auto_awesome',
        ),
      ];
    }
    final result = <FinancialInsight>[];
    final category = categories.entries.first;
    result.add(
      FinancialInsight(
        title: '${category.key} leads your spending',
        detail:
            'It represents ${(category.value / total * 100).round()}% of this month’s spending.',
        icon: 'category',
      ),
    );
    if (percent != null) {
      final direction = percent > 0 ? 'increased' : 'decreased';
      result.add(
        FinancialInsight(
          title: 'Month-over-month $direction',
          detail:
              'Spending is ${percent.abs().round()}% ${direction == 'increased' ? 'above' : 'below'} last month.',
          icon: direction == 'increased' ? 'trending_up' : 'trending_down',
        ),
      );
    }
    if (date.day > 7 &&
        total / date.day * DateTime(date.year, date.month + 1, 0).day >
            total * 1.2) {
      result.add(
        const FinancialInsight(
          title: 'Watch your pace',
          detail:
              'At this pace, this month could finish higher than today’s total.',
          icon: 'speed',
        ),
      );
    }
    return result;
  }
}
