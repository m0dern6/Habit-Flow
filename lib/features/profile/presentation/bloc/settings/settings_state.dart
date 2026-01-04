import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final String reminderSound;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.reminderSound = 'Default',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? reminderSound,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      reminderSound: reminderSound ?? this.reminderSound,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, reminderSound];
}
