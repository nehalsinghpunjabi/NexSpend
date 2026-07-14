import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../expenses/presentation/add_expense_sheet.dart';
import '../../expenses/presentation/expense_empty_state.dart';
import '../../expenses/presentation/expense_providers.dart';
import 'dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    if (metrics.monthlyTrend.every((point) => point.amount == 0)) {
      return const SafeArea(
        child: ExpenseEmptyState(
          icon: Icons.insights_outlined,
          title: 'Your money story starts here',
          message: 'Add an expense to unlock your spending overview.',
        ),
      );
    }
    final categoryEntries = metrics.categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final merchantEntries = metrics.merchants.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final recentExpenses = ref.watch(expensesProvider).value ?? const [];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 124),
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'A clear view of your financial momentum.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            children: [
              _MetricCard(label: 'This month', value: metrics.month),
              _MetricCard(label: 'Today', value: metrics.today),
              _MetricCard(label: 'Daily average', value: metrics.averageDaily),
              _MetricCard(
                label: 'Largest expense',
                value: metrics.largest?.amount ?? 0,
                detail: metrics.largest?.merchant ?? '—',
              ),
              _MetricCard(
                label: 'Remaining budget',
                value: 0,
                detail: 'Coming soon',
              ),
            ],
          ),
          const SizedBox(height: 28),
          _Section(
            title: 'Monthly spending trend',
            subtitle: 'Track your financial pace over time',
            child: SizedBox(
              height: 190,
              child: _LineChart(points: metrics.monthlyTrend),
            ),
          ),
          const SizedBox(height: 24),
          if (categoryEntries.isNotEmpty)
            _Section(
              title: 'Category breakdown',
              subtitle: 'Where your money is going this month',
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: _PieChart(entries: categoryEntries),
                  ),
                  const SizedBox(height: 16),
                  ...categoryEntries.map(
                    (entry) => _CategoryRow(
                      name: entry.key,
                      amount: entry.value,
                      total: metrics.month,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _Section(
            title: 'Spending history',
            subtitle: 'Your latest recorded activity',
            child: SizedBox(
              height: 160,
              child: _LineChart(points: metrics.recentTrend),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Top merchants',
            subtitle: 'The places you spend with most often',
            child: Column(
              children: merchantEntries
                  .take(5)
                  .map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(entry.key.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(entry.key),
                      subtitle: Text(
                        '${entry.value.count} transaction${entry.value.count == 1 ? '' : 's'}',
                      ),
                      trailing: Text(
                        '\u{20B9}${entry.value.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Recent expenses',
            subtitle: 'Your latest transactions',
            child: Column(
              children: recentExpenses
                  .take(4)
                  .map(
                    (expense) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddExpenseSheet(expense: expense),
                      ),
                      title: Text(expense.merchant),
                      subtitle: Text(
                        '${expense.category} · ${MaterialLocalizations.of(context).formatShortDate(expense.expenseDate)}',
                      ),
                      trailing: Text(
                        '\u{20B9}${expense.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, this.detail});
  final String label;
  final double value;
  final String? detail;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: NexSpendRadii.large,
      boxShadow: NexSpendEffects.cardShadow,
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            '\u{20B9}${value.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (detail != null)
            Text(
              detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      ],
      const SizedBox(height: 12),
      Container(
        decoration: const BoxDecoration(
          borderRadius: NexSpendRadii.large,
          boxShadow: NexSpendEffects.cardShadow,
        ),
        child: Card(
          child: Padding(padding: const EdgeInsets.all(18), child: child),
        ),
      ),
    ],
  );
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.points});
  final List<DashboardPoint> points;
  @override
  Widget build(BuildContext context) {
    final max = points.fold(
      0.0,
      (value, point) => point.amount > value ? point.amount : value,
    );
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: max == 0 ? 1 : max * 1.2,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                points[value.toInt().clamp(0, points.length - 1)].label,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .12),
            ),
            spots: List.generate(
              points.length,
              (index) => FlSpot(index.toDouble(), points[index].amount),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.entries});
  final List<MapEntry<String, double>> entries;
  @override
  Widget build(BuildContext context) => PieChart(
    PieChartData(
      centerSpaceRadius: 36,
      sectionsSpace: 3,
      sections: entries.take(5).toList().asMap().entries.map((indexed) {
        final colors = [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
          Theme.of(context).colorScheme.secondary,
          Colors.orange,
          Colors.pink,
        ];
        return PieChartSectionData(
          value: indexed.value.value,
          color: colors[indexed.key],
          radius: 46,
          title: '',
        );
      }).toList(),
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.total,
  });
  final String name;
  final double amount;
  final double total;
  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : amount / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),
              Text('\u{20B9}${amount.toStringAsFixed(0)}'),
              const SizedBox(width: 8),
              Text('${(percentage * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}
