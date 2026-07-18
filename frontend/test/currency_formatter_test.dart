import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/core/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats each supported currency with grouping', () {
      expect(const CurrencyFormatter('INR').format(2500), '₹2,500');
      expect(
        const CurrencyFormatter('USD').format(120, decimals: 2),
        r'$120.00',
      );
      expect(const CurrencyFormatter('EUR').format(999), '€999');
      expect(const CurrencyFormatter('GBP').format(1783), '£1,783');
    });

    test(
      'normalizes provider response currencies to the selected currency',
      () {
        const formatter = CurrencyFormatter('EUR');
        expect(
          formatter.normalizeResponseCurrencies('You spent ₹2,500 and \$120.'),
          'You spent €2,500 and €120.',
        );
      },
    );

    test('privacy masking does not reveal a currency value', () {
      expect(
        const CurrencyFormatter('USD').formatOrMask(120, hidden: true),
        '•••••',
      );
    });
  });
}
