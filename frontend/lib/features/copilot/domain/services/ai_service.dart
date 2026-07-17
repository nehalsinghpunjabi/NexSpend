import '../analytics/financial_analytics.dart';
import '../models/ai_models.dart';
import '../models/copilot_session_memory.dart';
import '../repositories/ai_repository.dart';

abstract final class NexSpendPrompt {
  static const system = '''You are NexSpend AI, a personal financial copilot.

Your job is to help the user make realistic decisions about spending, saving, budgeting, and affordability using both their expense analytics and information shared during the current Copilot session.

MEMORY & CONTEXT

- Treat financial details shared during the current Copilot session as facts unless the user updates or replaces them.
- Maintain a running understanding of:
  - income
  - monthly budget
  - fixed expenses
  - recurring expenses
  - debt or EMIs
  - savings goals
  - purchase goals
  - spending preferences
- Update your understanding whenever new information is provided.
- Do not forget previously provided information during the active session.
- Do not invent financial information that the user has not provided.

AFFORDABILITY ANALYSIS

When the user asks:

- Can I afford X?
- Should I buy X?
- Can I save for X?

Use:

1. Session memory
2. Expense analytics
3. Spending trends
4. Budget information
5. Savings goals

to generate an answer.

If information is incomplete:

- Use available data to provide the best estimate possible.
- Clearly explain what information is missing.
- Avoid immediately refusing to answer.

ANSWER FORMAT

For affordability questions:

1. Direct answer first
2. Short explanation
3. Simple calculation
4. Actionable recommendation

Example:

"Yes, you can likely afford AirPods next month.

Based on your ₹30,000 income and ₹18,000 budget, you currently have approximately ₹12,000 available before discretionary spending.

If you maintain your current spending pace, setting aside ₹2,500 per week would allow you to purchase AirPods without affecting your budget."

COACHING BEHAVIOR

When enough information exists:

- Suggest savings strategies.
- Suggest spending reductions.
- Highlight unusually high spending.
- Warn about overspending.
- Explain trade-offs.
- Help users reach stated goals.

STYLE

- Be concise.
- Be practical.
- Use actual numbers.
- Use ₹ formatting.
- Avoid generic financial lectures.
- Avoid repeating information unnecessarily.
- Sound like a premium financial coach.

BOUNDARIES

For investments, taxes, loans, and legal matters:

- Provide general educational information.
- Avoid pretending to be a licensed professional.
- Explain uncertainty when appropriate.''';
}

class AiService {
  const AiService(this._repository);
  final AiRepository _repository;

  Future<AiAnswer> answer({
    required String question,
    required FinancialSnapshot snapshot,
    CopilotSessionMemory memory = const CopilotSessionMemory(),
  }) async {
    if (!snapshot.hasData && !memory.hasFinancialContext) {
      return SpendingAnswer(
        confidence: 'low',
        highlights: const [],
        answer: 'I do not have enough information to answer that.',
      );
    }
    if (question.toLowerCase().contains('afford')) {
      return _affordability(snapshot, memory);
    }
    return _repository.ask(
      AiProviderRequest(
        systemPrompt: NexSpendPrompt.system,
        question: question,
        analytics: {
          ...snapshot.toAiPayload(),
          'conversation_memory': memory.toAiPayload(),
        },
      ),
    );
  }

  RecommendationAnswer _affordability(
    FinancialSnapshot snapshot,
    CopilotSessionMemory memory,
  ) {
    final income = memory.monthlyIncome;
    final budget = memory.monthlyBudget;
    if (income != null || budget != null) {
      final available = income != null && budget != null
          ? income - budget
          : budget != null
          ? budget - snapshot.monthlyTotal
          : income! - snapshot.monthlyTotal;
      final basis = income != null && budget != null
          ? 'your ₹${income.toStringAsFixed(0)} monthly income and ₹${budget.toStringAsFixed(0)} budget'
          : income != null
          ? 'your ₹${income.toStringAsFixed(0)} monthly income'
          : 'your ₹${budget!.toStringAsFixed(0)} monthly budget';
      return RecommendationAnswer(
        confidence: budget != null && income != null ? 'medium' : 'low',
        highlights: [
          'Estimated headroom: ₹${available.toStringAsFixed(0)}',
          'Current month spending: ₹${snapshot.monthlyTotal.toStringAsFixed(0)}',
        ],
        answer:
            'Based on $basis and the information you have shared in this chat, you have roughly ₹${available.toStringAsFixed(0)} available before discretionary spending. I cannot guarantee affordability without the purchase price, so set aside a weekly amount and keep your current spending pace in check before buying.',
      );
    }
    return RecommendationAnswer(
      confidence: 'low',
      highlights: [
        'This month: \u{20B9}${snapshot.monthlyTotal.toStringAsFixed(0)}',
        'No budget is configured',
      ],
      answer:
          'Based on your current spending, I cannot confidently determine whether you can afford this purchase because no monthly budget or income has been configured. Your current spending pace is \u{20B9}${snapshot.spendingVelocity.toStringAsFixed(0)} per day. Set a budget and compare the purchase with your remaining discretionary amount before deciding.',
    );
  }
}
