import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/presentation/splash_overlay.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_providers.dart';

class NexSpendApp extends ConsumerWidget {
  const NexSpendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp.router(
      title: 'NexSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (settings.theme) {
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.system => ThemeMode.system,
      },
      routerConfig: router,
      builder: (context, child) =>
          NexSpendSplashOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
