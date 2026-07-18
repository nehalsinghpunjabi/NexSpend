import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../data/repositories/supabase_expense_repository.dart';
import '../domain/entities/expense.dart';

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return const [];
  return ref.watch(expenseRepositoryProvider).getExpenses(user.id);
});

final expenseActionsProvider = Provider<ExpenseActions>(
  (ref) => ExpenseActions(ref),
);

class ExpenseActions {
  ExpenseActions(this._ref);
  final Ref _ref;

  Future<void> addExpense({
    required double amount,
    required String merchant,
    required String category,
    required String paymentMethod,
    required DateTime expenseDate,
    String? notes,
  }) async {
    final user = _ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      throw StateError('You must be signed in to add an expense.');
    }
    final now = DateTime.now().toUtc();
    final normalizedNotes = notes?.trim();
    await _ref
        .read(expenseRepositoryProvider)
        .addExpense(
          Expense(
            id: '',
            userId: user.id,
            amount: amount,
            merchant: merchant.trim(),
            category: category,
            paymentMethod: paymentMethod,
            expenseDate: expenseDate,
            notes: normalizedNotes?.isEmpty ?? true ? null : normalizedNotes,
            currency: _ref.read(settingsControllerProvider).currency,
            createdAt: now,
            updatedAt: now,
          ),
        );
    _ref.invalidate(expensesProvider);
  }

  Future<void> updateExpense({
    required Expense expense,
    required double amount,
    required String merchant,
    required String category,
    required String paymentMethod,
    required DateTime expenseDate,
    String? notes,
  }) async {
    final normalizedNotes = notes?.trim();
    await _ref
        .read(expenseRepositoryProvider)
        .updateExpense(
          expense.copyWith(
            amount: amount,
            merchant: merchant.trim(),
            category: category,
            paymentMethod: paymentMethod,
            expenseDate: expenseDate,
            notes: normalizedNotes,
            clearNotes: normalizedNotes?.isEmpty ?? true,
          ),
        );
    _ref.invalidate(expensesProvider);
  }

  Future<void> deleteExpense(Expense expense) async {
    await _ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
    _ref.invalidate(expensesProvider);
  }

  Future<void> restoreExpense(Expense expense) async {
    await _ref.read(expenseRepositoryProvider).addExpense(expense);
    _ref.invalidate(expensesProvider);
  }
}
