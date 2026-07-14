import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<Expense> addExpense(Expense expense);
  Future<Expense> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Future<List<Expense>> getExpenses(String userId);
}
