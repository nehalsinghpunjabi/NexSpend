import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_query.dart';

class ExpenseSearchField extends ConsumerStatefulWidget {
  const ExpenseSearchField({super.key});
  @override
  ConsumerState<ExpenseSearchField> createState() => _ExpenseSearchFieldState();
}

class _ExpenseSearchFieldState extends ConsumerState<ExpenseSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(expenseQueryProvider.notifier).setSearch(value),
    );
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: _search,
    decoration: InputDecoration(
      hintText: 'Search merchant, category, notes',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                _search('');
                setState(() {});
              },
            ),
      filled: true,
      fillColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .45),
    ),
  );
}
