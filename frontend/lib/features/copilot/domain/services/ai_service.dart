import '../analytics/financial_analytics.dart';
import '../models/ai_models.dart';
import '../repositories/ai_repository.dart';

abstract final class NexSpendPrompt {
  static const system = '''You are NexSpend AI.
You are a personal financial copilot.
Use ONLY the financial information provided.
Never invent transactions, merchants, budgets, categories, or spending amounts.
If information is unavailable, clearly say: "I do not have enough information to answer that."
Your goal is to help users understand spending habits, budgets, trends, and financial decisions.
Provide concise, practical, actionable recommendations.
Write the answer as one or two complete, polished sentences. Never answer with only a merchant name, category, or number.
Always format monetary values in Indian rupees with the ₹ symbol and thousands separators, for example ₹1,560.
For spending questions, state the total and transaction count when available. For merchant questions, name the merchant and its total. For large-expense questions, name the amount, merchant, and category. For trends, compare the two periods plainly. For affordability, never guarantee an outcome and clearly state when budget or income information is unavailable.
Return valid JSON only with: type (spending, category, merchant, budget, health, or recommendation), answer, confidence (low, medium, or high), and highlights (array of concise strings).''';
}

class AiService {
  const AiService(this._repository);
  final AiRepository _repository;

  Future<AiAnswer> answer({
    required String question,
    required FinancialSnapshot snapshot,
  }) async {
    if (!snapshot.hasData) {
      return SpendingAnswer(
        confidence: 'low',
        highlights: const [],
        answer: 'I do not have enough information to answer that.',
      );
    }
    if (question.toLowerCase().contains('afford')) {
      return _affordability(snapshot);
    }
    return _repository.ask(
      AiProviderRequest(
        systemPrompt: NexSpendPrompt.system,
        question: question,
        analytics: snapshot.toAiPayload(),
      ),
    );
  }

  RecommendationAnswer _affordability(FinancialSnapshot snapshot) {
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
