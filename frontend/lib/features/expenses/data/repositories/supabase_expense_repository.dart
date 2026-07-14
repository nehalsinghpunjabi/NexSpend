import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => SupabaseExpenseRepository(),
);

class SupabaseExpenseRepository implements ExpenseRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<Expense> addExpense(Expense expense) async {
    final row = await _client
        .from('expenses')
        .insert(expense.toInsertJson())
        .select()
        .single();
    return Expense.fromJson(row);
  }

  @override
  Future<void> deleteExpense(String expenseId) =>
      _client.from('expenses').delete().eq('id', expenseId);

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    final rows = await _client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(Expense.fromJson).toList(growable: false);
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    final row = await _client
        .from('expenses')
        .update(expense.toUpdateJson())
        .eq('id', expense.id)
        .select()
        .single();
    return Expense.fromJson(row);
  }
}
