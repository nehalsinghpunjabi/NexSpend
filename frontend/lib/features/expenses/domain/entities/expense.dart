class Expense {
  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.paymentMethod,
    required this.expenseDate,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String userId;
  final double amount;
  final String merchant;
  final String category;
  final String paymentMethod;
  final DateTime expenseDate;
  final String? notes;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? merchant,
    String? category,
    String? paymentMethod,
    DateTime? expenseDate,
    String? notes,
    bool clearNotes = false,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Expense(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    merchant: merchant ?? this.merchant,
    category: category ?? this.category,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    expenseDate: expenseDate ?? this.expenseDate,
    notes: clearNotes ? null : notes ?? this.notes,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    amount: double.parse(json['amount'].toString()),
    merchant: json['merchant'] as String,
    category: json['category'] as String,
    paymentMethod: json['payment_method'] as String,
    expenseDate: DateTime.parse(json['expense_date'] as String),
    notes: json['notes'] as String?,
    currency: json['currency'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'amount': amount,
    'merchant': merchant,
    'category': category,
    'payment_method': paymentMethod,
    'expense_date': expenseDate.toUtc().toIso8601String(),
    'notes': notes,
    'currency': currency,
  };

  Map<String, dynamic> toUpdateJson() => {
    'amount': amount,
    'merchant': merchant,
    'category': category,
    'payment_method': paymentMethod,
    'expense_date': expenseDate.toUtc().toIso8601String(),
    'notes': notes,
    'currency': currency,
  };
}
