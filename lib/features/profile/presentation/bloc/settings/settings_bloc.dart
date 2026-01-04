import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale_code';
  static const _soundKey = 'settings_reminder_sound';

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SetThemeMode>(_onSetThemeMode);
    on<SetLanguage>(_onSetLanguage);
    on<SetReminderSound>(_onSetReminderSound);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final themeString = prefs.getString(_themeKey);
    final localeCode = prefs.getString(_localeKey);
    final sound = prefs.getString(_soundKey);

    ThemeMode themeMode = ThemeMode.system;
    if (themeString == 'light') themeMode = ThemeMode.light;
    if (themeString == 'dark') themeMode = ThemeMode.dark;

    final locale = localeCode != null ? Locale(localeCode) : state.locale;

    emit(state.copyWith(
      themeMode: themeMode,
      locale: locale,
      reminderSound: sound ?? state.reminderSound,
    ));
  }

  Future<void> _onSetThemeMode(
    SetThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    await prefs.setString(_themeKey, _themeToString(event.themeMode));
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onSetLanguage(
    SetLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    await prefs.setString(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onSetReminderSound(
    SetReminderSound event,
    Emitter<SettingsState> emit,
  ) async {
    await prefs.setString(_soundKey, event.sound);
    emit(state.copyWith(reminderSound: event.sound));
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
