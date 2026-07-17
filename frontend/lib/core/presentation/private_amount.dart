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
    final hidden = ref.watch(
      settingsControllerProvider.select((value) => value.privacyMode),
    );
    return Text(
      hidden ? '•••••' : '\u{20B9}${amount.toStringAsFixed(decimals)}',
      style: style,
    );
  }
}
