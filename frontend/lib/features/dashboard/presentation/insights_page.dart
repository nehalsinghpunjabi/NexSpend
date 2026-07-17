import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/presentation/private_amount.dart';
import 'dashboard_providers.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final entries = metrics.categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final merchants = metrics.merchants.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
        children: [
          Text('Insights', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          _HealthCard(monthlyTotal: metrics.month),
          const SizedBox(height: 20),
          _Section(
            title: 'Monthly spending',
            child: _TrendBars(points: metrics.monthlyTrend),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Category breakdown',
            child: Column(
              children: entries
                  .map(
                    (entry) => _CategoryRow(
                      name: entry.key,
                      amount: entry.value,
                      total: metrics.month,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Top merchants',
            child: merchants.isEmpty
                ? const Text(
                    'Your top merchants will appear as you add expenses.',
                  )
                : Column(
                    children: merchants
                        .take(4)
                        .map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Text(
                                entry.key.substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${entry.value.count} transaction${entry.value.count == 1 ? '' : 's'}',
                            ),
                            trailing: PrivateAmountText(entry.value.amount),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Financial coaching',
            child: Column(
              children: [
                _InsightTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Use your Copilot',
                  detail:
                      'Ask about your spending patterns for a personalised action plan.',
                ),
                const SizedBox(height: 10),
                _InsightTile(
                  icon: Icons.trending_up_rounded,
                  title: 'Spending trend',
                  detail: metrics.month == 0
                      ? 'Start recording expenses to build your trend.'
                      : 'Your live charts update automatically as transactions change.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(radius: 19, child: Icon(icon, size: 18)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.monthlyTotal});
  final double monthlyTotal;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: NexSpendRadii.large,
        boxShadow: NexSpendEffects.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: TweenAnimationBuilder<double>(
              duration: NexSpendMotion.slow,
              tween: Tween(begin: 0, end: monthlyTotal == 0 ? 0 : .72),
              builder: (context, progress, child) => Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).round()}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Text('Good', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial health',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  monthlyTotal == 0
                      ? 'Add expenses to unlock your score.'
                      : 'Your spending data is building a healthy financial picture.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      Card(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ],
  );
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.points});
  final List<DashboardPoint> points;
  @override
  Widget build(BuildContext context) {
    final max = points.fold(
      0.0,
      (result, item) => item.amount > result ? item.amount : result,
    );
    assert(() {
      debugPrint(
        'Insights monthly series: ${points.map((point) => '${point.label}=${point.amount}').join(', ')}; hasNonZero=${points.any((point) => point.amount > 0)}',
      );
      return true;
    }());
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points
            .map(
              (point) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              duration: NexSpendMotion.slow,
                              curve: NexSpendMotion.enterCurve,
                              tween: Tween(
                                begin: 0,
                                end: max == 0 ? 0 : point.amount / max,
                              ),
                              builder: (context, value, child) => SizedBox(
                                height: constraints.maxHeight * value,
                                width: double.infinity,
                                child: child,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(point.label, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.total,
  });
  final String name;
  final double amount, total;
  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : amount / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text('${(ratio * 100).round()}%'),
              const SizedBox(width: 8),
              PrivateAmountText(amount),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            borderRadius: NexSpendRadii.pill,
          ),
        ],
      ),
    );
  }
}
