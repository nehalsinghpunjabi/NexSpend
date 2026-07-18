import '../../../../core/formatters/currency_formatter.dart';

class CopilotSessionMemory {
  const CopilotSessionMemory({
    this.monthlyIncome,
    this.monthlyBudget,
    this.rent,
    this.debt,
    this.goals = const [],
    this.recurringExpenses = const [],
    this.preferences = const [],
  });

  final double? monthlyIncome;
  final double? monthlyBudget;
  final double? rent;
  final double? debt;
  final List<String> goals;
  final List<String> recurringExpenses;
  final List<String> preferences;

  bool get hasFinancialContext =>
      monthlyIncome != null ||
      monthlyBudget != null ||
      rent != null ||
      debt != null ||
      goals.isNotEmpty ||
      recurringExpenses.isNotEmpty ||
      preferences.isNotEmpty;

  CopilotSessionMemory updateFromMessage(String message) {
    final normalized = message.trim();
    final income = _amountAfter(
      normalized,
      r'(?:monthly\s+)?(?:income|salary|earnings?)',
    );
    final budget = _amountAfter(normalized, r'(?:monthly\s+)?budget');
    final rent = _amountAfter(normalized, r'rent');
    final debt = _amountAfter(normalized, r'(?:debt|loan|emi)');
    return CopilotSessionMemory(
      monthlyIncome: income ?? monthlyIncome,
      monthlyBudget: budget ?? monthlyBudget,
      rent: rent ?? this.rent,
      debt: debt ?? this.debt,
      goals: _appendIfRelevant(
        goals,
        normalized,
        RegExp(
          r'\b(?:want to buy|saving for|save for|goal is|planning to buy)\b',
          caseSensitive: false,
        ),
      ),
      recurringExpenses: _appendIfRelevant(
        recurringExpenses,
        normalized,
        RegExp(
          r'\b(?:recurring|every month|monthly bill|subscription)\b',
          caseSensitive: false,
        ),
      ),
      preferences: _appendIfRelevant(
        preferences,
        normalized,
        RegExp(r'\b(?:prefer|risk|comfortable with)\b', caseSensitive: false),
      ),
    );
  }

  Map<String, dynamic> toAiPayload() => {
    'monthly_income': monthlyIncome,
    'monthly_budget': monthlyBudget,
    'rent': rent,
    'debt': debt,
    'goals': goals,
    'recurring_expenses': recurringExpenses,
    'financial_preferences': preferences,
    'scope':
        'This context was supplied by the user during this active chat only.',
  };

  static double? _amountAfter(String text, String label) {
    final match = RegExp(
      '$label[^0-9]*(?:${CurrencyFormatter.acceptedAmountPrefixPattern})?\\s*([0-9][0-9,]*(?:\\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    return match == null
        ? null
        : double.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  static List<String> _appendIfRelevant(
    List<String> values,
    String message,
    RegExp trigger,
  ) {
    if (!trigger.hasMatch(message) ||
        values.any((value) => value.toLowerCase() == message.toLowerCase())) {
      return values;
    }
    return [...values, message];
  }
}
