import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.currency = 'INR',
    this.theme = AppThemePreference.dark,
    this.notificationsEnabled = true,
    this.debitCardEnabled = false,
    this.creditCardEnabled = false,
    this.upiEnabled = false,
    this.upiId,
    this.biometricEnabled = false,
    this.privacyMode = false,
  });

  final String currency;
  final AppThemePreference theme;
  final bool notificationsEnabled;
  final bool debitCardEnabled, creditCardEnabled, upiEnabled;
  final String? upiId;
  final bool biometricEnabled, privacyMode;

  AppSettings copyWith({
    String? currency,
    AppThemePreference? theme,
    bool? notificationsEnabled,
    bool? debitCardEnabled,
    bool? creditCardEnabled,
    bool? upiEnabled,
    String? upiId,
    bool clearUpiId = false,
    bool? biometricEnabled,
    bool? privacyMode,
  }) => AppSettings(
    currency: currency ?? this.currency,
    theme: theme ?? this.theme,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    debitCardEnabled: debitCardEnabled ?? this.debitCardEnabled,
    creditCardEnabled: creditCardEnabled ?? this.creditCardEnabled,
    upiEnabled: upiEnabled ?? this.upiEnabled,
    upiId: clearUpiId ? null : upiId ?? this.upiId,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    privacyMode: privacyMode ?? this.privacyMode,
  );
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _currencyKey = 'settings.currency';
  static const _themeKey = 'settings.theme';
  static const _notificationsKey = 'settings.notifications';
  static const _debitKey = 'settings.debit';
  static const _creditKey = 'settings.credit';
  static const _upiKey = 'settings.upi';
  static const _upiIdKey = 'settings.upi_id';
  static const _biometricKey = 'settings.biometric';
  static const _privacyKey = 'settings.privacy';

  @override
  AppSettings build() {
    _restore();
    return const AppSettings();
  }

  ThemeMode get themeMode => switch (state.theme) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
    AppThemePreference.system => ThemeMode.system,
  };

  Future<void> setCurrency(String currency) =>
      _save(state.copyWith(currency: currency));
  Future<void> setTheme(AppThemePreference theme) =>
      _save(state.copyWith(theme: theme));
  Future<void> setNotificationsEnabled(bool enabled) =>
      _save(state.copyWith(notificationsEnabled: enabled));

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    final theme = switch (savedTheme) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.dark,
    };
    state = AppSettings(
      currency: prefs.getString(_currencyKey) ?? 'INR',
      theme: theme,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      debitCardEnabled: prefs.getBool(_debitKey) ?? false,
      creditCardEnabled: prefs.getBool(_creditKey) ?? false,
      upiEnabled: prefs.getBool(_upiKey) ?? false,
      upiId: prefs.getString(_upiIdKey),
      biometricEnabled: prefs.getBool(_biometricKey) ?? false,
      privacyMode: prefs.getBool(_privacyKey) ?? false,
    );
  }

  Future<void> _save(AppSettings value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_currencyKey, value.currency),
      prefs.setString(_themeKey, value.theme.name),
      prefs.setBool(_notificationsKey, value.notificationsEnabled),
      prefs.setBool(_debitKey, value.debitCardEnabled),
      prefs.setBool(_creditKey, value.creditCardEnabled),
      prefs.setBool(_upiKey, value.upiEnabled),
      prefs.setBool(_biometricKey, value.biometricEnabled),
      prefs.setBool(_privacyKey, value.privacyMode),
      if (value.upiId == null)
        prefs.remove(_upiIdKey)
      else
        prefs.setString(_upiIdKey, value.upiId!),
    ]);
  }

  Future<void> setDebitCardEnabled(bool value) =>
      _save(state.copyWith(debitCardEnabled: value));
  Future<void> setCreditCardEnabled(bool value) =>
      _save(state.copyWith(creditCardEnabled: value));
  Future<void> setUpi({
    required bool enabled,
    String? id,
    bool clearId = false,
  }) => _save(
    state.copyWith(upiEnabled: enabled, upiId: id, clearUpiId: clearId),
  );
  Future<void> setBiometricEnabled(bool value) =>
      _save(state.copyWith(biometricEnabled: value));
  Future<void> setPrivacyMode(bool value) =>
      _save(state.copyWith(privacyMode: value));
}
