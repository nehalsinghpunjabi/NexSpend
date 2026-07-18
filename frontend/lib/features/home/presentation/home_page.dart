import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/design_tokens.dart';
import '../../copilot/presentation/copilot_page.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../dashboard/presentation/insights_page.dart';
import '../../expenses/presentation/add_expense_sheet.dart';
import '../../expenses/presentation/expenses_page.dart';
import '../../settings/presentation/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AnimatedSwitcher(
      duration: NexSpendMotion.standard,
      reverseDuration: NexSpendMotion.fast,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(.045, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_index),
        child: switch (_index) {
          0 => DashboardPage(onOpenSettings: () => _openSettings(context)),
          1 => const ExpensesPage(),
          2 => const CopilotPage(),
          _ => const InsightsPage(),
        },
      ),
    ),
    bottomNavigationBar: _BottomNavigation(
      selectedIndex: _index,
      onSelected: (index) {
        if (index != _index) HapticFeedback.selectionClick();
        setState(() => _index = index);
      },
      onAdd: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddExpenseSheet(),
        );
      },
    ),
  );

  void _openSettings(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: .35),
            ),
          ),
        ),
        child: Row(
          children: [
            _NavItem(
              index: 0,
              selectedIndex: selectedIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              onSelected: onSelected,
            ),
            _NavItem(
              index: 1,
              selectedIndex: selectedIndex,
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart,
              label: 'Expenses',
              onSelected: onSelected,
            ),
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: NexSpendMotion.standard,
                  tween: Tween(begin: 0.92, end: 1),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: IconButton(
                    tooltip: 'Add expense',
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      fixedSize: const Size(56, 56),
                      elevation: 12,
                      shadowColor: scheme.primary.withValues(alpha: .55),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 30),
                  ),
                ),
              ),
            ),
            _NavItem(
              index: 2,
              selectedIndex: selectedIndex,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Copilot',
              onSelected: onSelected,
            ),
            _NavItem(
              index: 3,
              selectedIndex: selectedIndex,
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: 'Insights',
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onSelected,
  });
  final int index, selectedIndex;
  final IconData icon, activeIcon;
  final String label;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label tab${selected ? ', selected' : ''}',
        child: InkWell(
          onTap: () => onSelected(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: NexSpendMotion.fast,
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey(selected),
                  size: 21,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
