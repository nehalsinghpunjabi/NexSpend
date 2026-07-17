import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class NexSpendSplashOverlay extends StatefulWidget {
  const NexSpendSplashOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<NexSpendSplashOverlay> createState() => _NexSpendSplashOverlayState();
}

class _NexSpendSplashOverlayState extends State<NexSpendSplashOverlay> {
  var _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1150), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      IgnorePointer(
        ignoring: !_visible,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: NexSpendMotion.standard,
          onEnd: () {
            if (mounted && !_visible) setState(() {});
          },
          child: const _SplashContent(),
        ),
      ),
    ],
  );
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF080811),
    child: Center(
      child: TweenAnimationBuilder<double>(
        duration: NexSpendMotion.slow,
        tween: Tween(begin: .88, end: 1),
        curve: NexSpendMotion.enterCurve,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: NexSpendGradients.hero,
                borderRadius: NexSpendRadii.large,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x666C63FF),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'NexSpend AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Talk to your money.',
              style: TextStyle(color: Color(0xFF9CA3C7), fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}
