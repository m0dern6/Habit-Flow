import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class SetThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const SetThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SetLanguage extends SettingsEvent {
  final Locale locale;

  const SetLanguage(this.locale);

  @override
  List<Object?> get props => [locale];
}

class SetReminderSound extends SettingsEvent {
  final String sound;

  const SetReminderSound(this.sound);

  @override
  List<Object?> get props => [sound];
}
