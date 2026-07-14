import 'package:flutter_test/flutter_test.dart';
import 'package:nexspend/features/expenses/domain/entities/expense.dart';

void main() {
  final expense = Expense(
    id: 'expense-id',
    userId: 'user-id',
    amount: 249.5,
    merchant: 'Nex Cafe',
    category: 'Food & Dining',
    paymentMethod: 'UPI',
    expenseDate: DateTime.utc(2026, 7, 14),
    notes: 'Lunch',
    currency: 'INR',
    createdAt: DateTime.utc(2026, 7, 14),
    updatedAt: DateTime.utc(2026, 7, 14),
  );

  test('serializes and deserializes expense data', () {
    final json = {
      ...expense.toInsertJson(),
      'id': expense.id,
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
    };

    expect(Expense.fromJson(json).merchant, 'Nex Cafe');
    expect(Expense.fromJson(json).amount, 249.5);
  });

  test('copyWith preserves unspecified values', () {
    final updated = expense.copyWith(amount: 300, clearNotes: true);
    expect(updated.amount, 300);
    expect(updated.notes, isNull);
    expect(updated.merchant, expense.merchant);
  });
}
