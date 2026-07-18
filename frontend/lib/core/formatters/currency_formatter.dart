/// Presentation-only formatting for the currency the user has selected.
///
/// Expense amounts remain numeric in storage and analytics; selecting a
/// currency changes how those amounts are presented throughout the app.
class CurrencyFormatter {
  const CurrencyFormatter(this.code);

  final String code;

  static const _symbols = <String, String>{
    'INR': '₹',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
  };

  static const supportedCodes = <String>['INR', 'USD', 'EUR', 'GBP'];

  String get symbol => _symbols[code] ?? _symbols['INR']!;

  String format(double amount, {int decimals = 0}) {
    final fixed = amount.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = parts.first;
    final grouped = StringBuffer();
    for (var index = 0; index < whole.length; index++) {
      if (index > 0 && (whole.length - index) % 3 == 0) grouped.write(',');
      grouped.write(whole[index]);
    }
    final sign = amount < 0 ? '-' : '';
    final fraction = parts.length == 2 ? '.${parts.last}' : '';
    return '$sign$symbol$grouped$fraction';
  }

  String formatOrMask(
    double amount, {
    required bool hidden,
    int decimals = 0,
  }) => hidden ? '•••••' : format(amount, decimals: decimals);

  /// Replaces known currency symbols in provider responses with the active
  /// presentation currency without altering the underlying numeric value.
  String normalizeResponseCurrencies(String text) => text.replaceAllMapped(
    RegExp(
      r'(?:₹|\$|€|£|Rs\.?|INR|USD|EUR|GBP)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    ),
    (match) => '$symbol${match.group(1)}',
  );

  static const acceptedAmountPrefixPattern =
      r'(?:₹|\$|€|£|rs\.?|inr|usd|eur|gbp|rupees?|dollars?|euros?|pounds?)';
}
