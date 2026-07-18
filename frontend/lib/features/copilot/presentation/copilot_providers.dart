import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/ai_config.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/providers/groq_provider.dart';
import '../data/providers/openai_provider.dart';
import '../data/repositories/provider_ai_repository.dart';
import '../domain/analytics/financial_analytics.dart';
import '../domain/models/ai_models.dart';
import '../domain/models/copilot_session_memory.dart';
import '../domain/providers/ai_provider.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/services/ai_service.dart';

final financialSnapshotProvider = Provider<FinancialSnapshot>(
  (ref) =>
      FinancialAnalytics.build(ref.watch(expensesProvider).value ?? const []),
);
final financialInsightsProvider = Provider<List<FinancialInsight>>(
  (ref) => ref.watch(financialSnapshotProvider).insights,
);
final aiProviderProvider = Provider<AiProvider>(
  (ref) => AiConfig.provider == AiProviderKind.groq
      ? GroqProvider()
      : OpenAiProvider(),
);
final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => ProviderAiRepository(ref.watch(aiProviderProvider)),
);
final aiServiceProvider = Provider<AiService>(
  (ref) => AiService(
    ref.watch(aiRepositoryProvider),
    ref.watch(currencyFormatterProvider),
  ),
);
final copilotControllerProvider =
    NotifierProvider<CopilotController, List<AiChatMessage>>(
      CopilotController.new,
    );

class CopilotController extends Notifier<List<AiChatMessage>> {
  var _memory = const CopilotSessionMemory();
  @override
  List<AiChatMessage> build() => const [];

  Future<void> send(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;
    _memory = _memory.updateFromMessage(trimmed);
    final now = DateTime.now();
    final pendingId = 'pending-${now.microsecondsSinceEpoch}';
    state = [
      ...state,
      AiChatMessage(
        id: 'user-${now.microsecondsSinceEpoch}',
        role: AiMessageRole.user,
        text: trimmed,
        createdAt: now,
      ),
      AiChatMessage(
        id: pendingId,
        role: AiMessageRole.assistant,
        text: '',
        createdAt: now,
        isLoading: true,
      ),
    ];
    try {
      final answer = await ref
          .read(aiServiceProvider)
          .answer(
            question: trimmed,
            snapshot: ref.read(financialSnapshotProvider),
            memory: _memory,
          );
      final formatter = ref.read(currencyFormatterProvider);
      _replace(
        pendingId,
        AiChatMessage(
          id: pendingId,
          role: AiMessageRole.assistant,
          text: formatter.normalizeResponseCurrencies(answer.answer),
          createdAt: DateTime.now(),
        ),
      );
    } catch (error) {
      _replace(
        pendingId,
        AiChatMessage(
          id: pendingId,
          role: AiMessageRole.assistant,
          text: error.toString(),
          createdAt: DateTime.now(),
          isError: true,
        ),
      );
    }
  }

  void clear() {
    _memory = const CopilotSessionMemory();
    state = const [];
  }

  void _replace(String id, AiChatMessage message) =>
      state = [for (final item in state) item.id == id ? message : item];
}
