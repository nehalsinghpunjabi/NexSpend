import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../expenses/presentation/expense_providers.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.today,
    required this.month,
    required this.averageDaily,
    required this.largest,
    required this.categories,
    required this.merchants,
    required this.monthlyTrend,
    required this.recentTrend,
  });
  final double today;
  final double month;
  final double averageDaily;
  final Expense? largest;
  final Map<String, double> categories;
  final Map<String, MerchantMetric> merchants;
  final List<DashboardPoint> monthlyTrend;
  final List<DashboardPoint> recentTrend;
}

class DashboardPoint {
  const DashboardPoint(this.label, this.amount);
  final String label;
  final double amount;
}

class MerchantMetric {
  const MerchantMetric(this.amount, this.count);
  final double amount;
  final int count;
}

final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisMonth = expenses
      .where(
        (item) =>
            item.expenseDate.toLocal().year == now.year &&
            item.expenseDate.toLocal().month == now.month,
      )
      .toList();
  final todayTotal = expenses
      .where((item) {
        final date = item.expenseDate.toLocal();
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      })
      .fold(0.0, (sum, item) => sum + item.amount);
  final monthTotal = thisMonth.fold(0.0, (sum, item) => sum + item.amount);
  final elapsedDays = now.day;
  final categories = <String, double>{};
  final merchants = <String, MerchantMetric>{};
  for (final item in thisMonth) {
    categories[item.category] = (categories[item.category] ?? 0) + item.amount;
    final current = merchants[item.merchant] ?? const MerchantMetric(0, 0);
    merchants[item.merchant] = MerchantMetric(
      current.amount + item.amount,
      current.count + 1,
    );
  }
  final trend = List.generate(6, (index) {
    final month = DateTime(now.year, now.month - 5 + index);
    final total = expenses
        .where((item) {
          final date = item.expenseDate.toLocal();
          return date.year == month.year && date.month == month.month;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
    return DashboardPoint(_monthLabel(month.month), total);
  });
  final recent = List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final total = expenses
        .where((item) {
          final date = item.expenseDate.toLocal();
          return date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
        })
        .fold(0.0, (sum, item) => sum + item.amount);
    return DashboardPoint('${day.day}', total);
  });
  Expense? largest;
  for (final item in thisMonth) {
    if (largest == null || item.amount > largest.amount) largest = item;
  }
  return DashboardMetrics(
    today: todayTotal,
    month: monthTotal,
    averageDaily: monthTotal / elapsedDays,
    largest: largest,
    categories: categories,
    merchants: merchants,
    monthlyTrend: trend,
    recentTrend: recent,
  );
});
String _monthLabel(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
