import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/entities/expense.dart';
import 'expense_providers.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  static const _categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Other',
  ];
  static const _paymentMethods = [
    'UPI',
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Other',
  ];
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = _categories.first;
  String _paymentMethod = _paymentMethods.first;
  DateTime? _expenseDate = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.expense != null;

  bool get _isValid =>
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _merchantController.text.trim().isNotEmpty &&
      _expenseDate != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _amountController.text = expense.amount.toStringAsFixed(2);
      _merchantController.text = expense.merchant;
      _notesController.text = expense.notes ?? '';
      _category = _categories.contains(expense.category)
          ? expense.category
          : _categories.last;
      _paymentMethod = _paymentMethods.contains(expense.paymentMethod)
          ? expense.paymentMethod
          : _paymentMethods.last;
      _expenseDate = expense.expenseDate;
    }
    _amountController.addListener(_refresh);
    _merchantController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_isValid || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final actions = ref.read(expenseActionsProvider);
      if (_isEditing) {
        await actions.updateExpense(
          expense: widget.expense!,
          amount: double.parse(_amountController.text.trim()),
          merchant: _merchantController.text,
          category: _category,
          paymentMethod: _paymentMethod,
          expenseDate: _expenseDate!,
          notes: _notesController.text,
        );
      } else {
        await actions.addExpense(
          amount: double.parse(_amountController.text.trim()),
          merchant: _merchantController.text,
          category: _category,
          paymentMethod: _paymentMethod,
          expenseDate: _expenseDate!,
          notes: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save expense: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: NexSpendRadii.pill,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isEditing ? 'Edit expense' : 'Add expense',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                autofocus: !_isEditing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                validator: (value) =>
                    (double.tryParse(value?.trim() ?? '') ?? 0) > 0
                    ? null
                    : 'Enter an amount greater than zero',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _merchantController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Merchant'),
                validator: (value) => value?.trim().isNotEmpty == true
                    ? null
                    : 'Merchant is required',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: _paymentMethods
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _expenseDate == null
                      ? 'Select date'
                      : 'Date: ${MaterialLocalizations.of(context).formatMediumDate(_expenseDate!)}',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isValid && !_saving ? _save : null,
                icon: _saving
                    ? const SizedBox.shrink()
                    : Icon(
                        _isEditing ? Icons.check_rounded : Icons.add_rounded,
                      ),
                label: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update expense' : 'Save expense'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
