import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/settings_providers.dart';

class PrivateAmountText extends ConsumerWidget {
  const PrivateAmountText(
    this.amount, {
    super.key,
    this.style,
    this.decimals = 0,
  });

  final double amount;
  final TextStyle? style;
  final int decimals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final formatter = ref.watch(currencyFormatterProvider);
    final value = formatter.formatOrMask(
      amount,
      hidden: settings.privacyMode,
      decimals: decimals,
    );
    return Semantics(
      label: settings.privacyMode ? 'Monetary amount hidden' : value,
      excludeSemantics: true,
      child: Text(value, style: style),
    );
  }
}
