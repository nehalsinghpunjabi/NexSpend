import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/models/ai_models.dart';
import 'copilot_providers.dart';

class CopilotPage extends ConsumerStatefulWidget {
  const CopilotPage({super.key});
  @override
  ConsumerState<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends ConsumerState<CopilotPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  static const _suggestions = [
    'Where did I spend the most this month?',
    'How much did I spend on food?',
    'Compare this month to last month.',
    'What are my largest expenses?',
    'Which categories are increasing?',
    'How can I save more money?',
    'Can I afford a purchase this month?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? value]) {
    final question = value ?? _controller.text;
    _controller.clear();
    ref.read(copilotControllerProvider.notifier).send(question);
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = ref.watch(copilotControllerProvider);
    final insights = ref.watch(financialInsightsProvider);
    final snapshot = ref.watch(financialSnapshotProvider);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: NexSpendRadii.medium,
                    boxShadow: NexSpendEffects.cardShadow,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NexSpend AI',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your data-backed financial copilot',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Clear conversation',
                  onPressed: messages.isEmpty
                      ? null
                      : ref.read(copilotControllerProvider.notifier).clear,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              children: [
                if (messages.isEmpty) ...[
                  _HeroCard(
                    score: snapshot.healthScore,
                    hasData: snapshot.hasData,
                  ),
                  const SizedBox(height: NexSpendSpace.lg),
                  Text(
                    'Your latest insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final insight in insights)
                    _InsightCard(
                      title: insight.title,
                      detail: insight.detail,
                      icon: insight.icon,
                    ),
                  const SizedBox(height: NexSpendSpace.lg),
                  Text(
                    'Ask NexSpend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions
                        .map(
                          (suggestion) => ActionChip(
                            avatar: const Icon(
                              Icons.auto_awesome_outlined,
                              size: 16,
                            ),
                            label: Text(suggestion),
                            onPressed: () => _send(suggestion),
                          ),
                        )
                        .toList(),
                  ),
                ],
                for (final message in messages) _ChatBubble(message: message),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              onSubmitted: _send,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask about your spending…',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: NexSpendRadii.large,
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Send',
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  onPressed: _send,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.score, required this.hasData});
  final int score;
  final bool hasData;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(NexSpendSpace.lg),
      decoration: BoxDecoration(
        gradient: NexSpendGradients.hero,
        borderRadius: NexSpendRadii.large,
        boxShadow: NexSpendEffects.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surface.withValues(alpha: .9),
            ),
            child: Text(
              '$score',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData ? 'Your financial pulse' : 'Your copilot is ready',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasData
                      ? 'Use your real expense activity to uncover patterns.'
                      : 'Start logging expenses to unlock personalised insights.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.detail,
    required this.icon,
  });
  final String title, detail, icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(_icon, color: scheme.onSecondaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(detail),
      ),
    );
  }

  IconData get _icon => switch (icon) {
    'trending_up' => Icons.trending_up,
    'trending_down' => Icons.trending_down,
    'category' => Icons.category_outlined,
    'speed' => Icons.speed_outlined,
    _ => Icons.auto_awesome_outlined,
  };
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final AiChatMessage message;
  @override
  Widget build(BuildContext context) {
    final mine = message.role == AiMessageRole.user;
    final scheme = Theme.of(context).colorScheme;
    final color = mine
        ? scheme.primary
        : message.isError
        ? scheme.errorContainer
        : scheme.surfaceContainerHighest;
    final foreground = mine
        ? scheme.onPrimary
        : message.isError
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: color,
            borderRadius: NexSpendRadii.medium.copyWith(
              bottomRight: mine ? const Radius.circular(4) : null,
              bottomLeft: mine ? null : const Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isLoading)
                SizedBox(
                  width: 72,
                  height: 20,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thinking…',
                        style: TextStyle(color: foreground, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  message.text,
                  style: TextStyle(color: foreground, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(TimeOfDay.fromDateTime(message.createdAt)),
                  style: TextStyle(
                    color: foreground.withValues(alpha: .65),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
