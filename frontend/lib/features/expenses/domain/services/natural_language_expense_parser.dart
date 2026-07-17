class ParsedExpenseDraft {
  const ParsedExpenseDraft({
    required this.amount,
    required this.merchant,
    required this.category,
    required this.confidence,
  });

  final double? amount;
  final String? merchant;
  final String category;
  final double confidence;

  bool get isComplete => amount != null && amount! > 0 && merchant != null;
}

class NaturalLanguageExpenseParser {
  const NaturalLanguageExpenseParser();

  ParsedExpenseDraft parse(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    final amount = _amount(normalized);
    final merchant = _merchant(normalized);
    final category = _category(normalized);
    final confidence = amount != null && merchant != null
        ? (_hasExpenseIntent(normalized) ? .95 : .75)
        : .25;
    return ParsedExpenseDraft(
      amount: amount,
      merchant: merchant,
      category: category,
      confidence: confidence,
    );
  }

  double? _amount(String text) {
    final match = RegExp(
      r'(?:₹|rs\.?|inr|rupees?)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)|\b([0-9][0-9,]*(?:\.[0-9]{1,2})?)\b',
      caseSensitive: false,
    ).firstMatch(text);
    final raw = match?.group(1) ?? match?.group(2);
    return raw == null ? null : double.tryParse(raw.replaceAll(',', ''));
  }

  String? _merchant(String text) {
    final patterns = [
      RegExp(
        r'\b(?:at|on|for)\s+(.+?)(?:\s*(?:for|on|at)\s*(?:₹|rs\.?|inr|rupees?|\d)|$)',
        caseSensitive: false,
      ),
      RegExp(r'^(.+?)\s+(?:₹|rs\.?|inr|rupees?|\d)', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final value = pattern.firstMatch(text)?.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return value
            .replaceFirst(
              RegExp(r'^(?:spent|paid|bought)\s+', caseSensitive: false),
              '',
            )
            .trim();
      }
    }
    return null;
  }

  String _category(String text) {
    final value = text.toLowerCase();
    if (RegExp(
      r'coffee|lunch|food|zomato|swiggy|restaurant|starbucks',
    ).hasMatch(value)) {
      return 'Food & Dining';
    }
    if (RegExp(r'uber|ola|petrol|fuel|ride|metro|taxi').hasMatch(value)) {
      return 'Transport';
    }
    if (RegExp(r'grocery|groceries|market|supermarket').hasMatch(value)) {
      return 'Bills';
    }
    if (RegExp(r'movie|netflix|spotify|concert').hasMatch(value)) {
      return 'Entertainment';
    }
    if (RegExp(r'pharmacy|doctor|hospital|health').hasMatch(value)) {
      return 'Health';
    }
    if (RegExp(r'shop|bought|amazon|store').hasMatch(value)) {
      return 'Shopping';
    }
    return 'Other';
  }

  bool _hasExpenseIntent(String text) => RegExp(
    r'\b(spent|paid|bought|purchase|ride)\b',
    caseSensitive: false,
  ).hasMatch(text);
}
