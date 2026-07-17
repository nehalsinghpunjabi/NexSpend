import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/features/expenses/domain/services/natural_language_expense_parser.dart';

void main() {
  const parser = NaturalLanguageExpenseParser();

  test('extracts a restaurant expense', () {
    final result = parser.parse('Spent ₹450 at Starbucks');
    expect(result.amount, 450);
    expect(result.merchant, 'Starbucks');
    expect(result.category, 'Food & Dining');
    expect(result.isComplete, isTrue);
  });

  test('extracts a transport expense', () {
    final result = parser.parse('Uber ride ₹250');
    expect(result.amount, 250);
    expect(result.merchant, 'Uber ride');
    expect(result.category, 'Transport');
  });
}
