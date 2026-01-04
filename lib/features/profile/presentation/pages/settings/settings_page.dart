import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/neumorphic_section.dart';
import '../../../../../core/widgets/neumorphic_button.dart';
import '../../widgets/account_actions_section.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const NeumorphicSection(
              title: 'Profile',
              icon: Icons.person_outline_rounded,
              child: _ProfileSection(),
            ),
            const SizedBox(height: 24),
            const NeumorphicSection(
              title: 'Personalization',
              icon: Icons.palette_outlined,
              child: _PersonalizationSection(),
            ),
            const SizedBox(height: 24),
            const NeumorphicSection(
              title: 'Preferences',
              icon: Icons.tune_rounded,
              child: _PreferencesSection(),
            ),
            const SizedBox(height: 24),
            const NeumorphicSection(
              title: 'Data & Privacy',
              icon: Icons.shield_outlined,
              child: _DataPrivacySection(),
            ),
            const SizedBox(height: 24),
            const NeumorphicSection(
              title: 'Support',
              icon: Icons.help_outline_rounded,
              child: _SupportSection(),
            ),
            const SizedBox(height: 24),
            const NeumorphicSection(
              title: 'Account',
              icon: Icons.person_pin_rounded,
              child: AccountActionsSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _action(
          context,
          title: 'Edit Profile',
          subtitle: 'Manage your personal info',
          icon: Icons.edit_rounded,
          onTap: () => context.push('/profile/edit'),
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            _action(
              context,
              title: 'Notifications',
              subtitle: 'Alerts & reminders',
              icon: Icons.notifications_none_rounded,
              onTap: () => context.push('/profile/notifications'),
            ),
            _action(
              context,
              title: 'Privacy & Security',
              subtitle: 'Data and safety',
              icon: Icons.security_rounded,
              onTap: () => context.push('/profile/privacy'),
            ),
            _action(
              context,
              title: 'Reminder Sounds',
              subtitle: state.reminderSound,
              icon: Icons.music_note_outlined,
              onTap: () => _showSoundSheet(context, state.reminderSound),
            ),
          ],
        );
      },
    );
  }
}

class _PersonalizationSection extends StatelessWidget {
  const _PersonalizationSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            _action(
              context,
              title: 'Theme',
              subtitle: _themeLabel(state.themeMode),
              icon: Icons.brightness_6_rounded,
              onTap: () => _showThemeSheet(context, state.themeMode),
            ),
            _action(
              context,
              title: 'Language',
              subtitle: _languageLabel(state.locale),
              icon: Icons.language_rounded,
              onTap: () => _showLanguageSheet(context, state.locale),
            ),
          ],
        );
      },
    );
  }
}

class _DataPrivacySection extends StatelessWidget {
  const _DataPrivacySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _action(
          context,
          title: 'Export Data',
          subtitle: 'Download your habit data',
          icon: Icons.download_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export flow coming soon.')),
            );
          },
        ),
        _action(
          context,
          title: 'Clear Cache',
          subtitle: 'Free up local storage',
          icon: Icons.cleaning_services_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache clearing coming soon.')),
            );
          },
        ),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _action(
          context,
          title: 'Help & Support',
          subtitle: 'FAQs and contact',
          icon: Icons.help_outline_rounded,
          onTap: () => context.push('/profile/help'),
        ),
        _action(
          context,
          title: 'App Info & Version',
          subtitle: 'Build, licenses, acknowledgements',
          icon: Icons.info_outline_rounded,
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Habit Flow',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.self_improvement, size: 32),
              children: const [
                Text('Track habits, stay consistent, and keep your streaks.'),
              ],
            );
          },
        ),
        _action(
          context,
          title: 'Rate the App',
          subtitle: 'Share feedback to help us improve',
          icon: Icons.star_border_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rating flow coming soon.'),
              ),
            );
          },
        ),
        _action(
          context,
          title: 'Send Feedback',
          subtitle: 'Tell us what to improve',
          icon: Icons.feedback_outlined,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Feedback flow coming soon.'),
              ),
            );
          },
        ),
      ],
    );
  }
}

String _themeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
    default:
      return 'System default';
  }
}

String _languageLabel(Locale locale) {
  switch (locale.languageCode) {
    case 'es':
      return 'Español';
    case 'fr':
      return 'Français';
    case 'en':
    default:
      return 'English';
  }
}

void _showThemeSheet(BuildContext context, ThemeMode current) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose theme',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _optionTile(
                context: sheetContext,
                title: 'System default',
                subtitle: 'Match your device setting',
                icon: Icons.brightness_auto_rounded,
                selected: current == ThemeMode.system,
                onTap: () {
                  context.read<SettingsBloc>().add(
                        const SetThemeMode(ThemeMode.system),
                      );
                  Navigator.of(sheetContext).pop();
                },
              ),
              _optionTile(
                context: sheetContext,
                title: 'Light',
                subtitle: 'Brighter look and feel',
                icon: Icons.light_mode_rounded,
                selected: current == ThemeMode.light,
                onTap: () {
                  context.read<SettingsBloc>().add(
                        const SetThemeMode(ThemeMode.light),
                      );
                  Navigator.of(sheetContext).pop();
                },
              ),
              _optionTile(
                context: sheetContext,
                title: 'Dark',
                subtitle: 'Dimmer, eye-friendly mode',
                icon: Icons.dark_mode_rounded,
                selected: current == ThemeMode.dark,
                onTap: () {
                  context.read<SettingsBloc>().add(
                        const SetThemeMode(ThemeMode.dark),
                      );
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showLanguageSheet(BuildContext context, Locale current) {
  const languageOptions = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App language',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              for (final locale in languageOptions)
                _optionTile(
                  context: sheetContext,
                  title: _languageLabel(locale),
                  subtitle: 'Use ${_languageLabel(locale)} in-app labels',
                  icon: Icons.translate_rounded,
                  selected: current.languageCode == locale.languageCode,
                  onTap: () {
                    context.read<SettingsBloc>().add(SetLanguage(locale));
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _showSoundSheet(BuildContext context, String current) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _SoundSelectionSheet(currentSound: current),
  );
}

class _SoundSelectionSheet extends StatefulWidget {
  final String currentSound;

  const _SoundSelectionSheet({required this.currentSound});

  @override
  State<_SoundSelectionSheet> createState() => _SoundSelectionSheetState();
}

class _SoundSelectionSheetState extends State<_SoundSelectionSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingSound;

  static const soundOptions = [
    'Default',
    'Soft chime',
    'Bright bell',
    'Gentle wave',
    'Vibrate only',
  ];

  // Map sound names to online demo URLs (free notification sounds)
  static const soundAssets = {
    'Default':
        'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
    'Soft chime':
        'https://assets.mixkit.co/active_storage/sfx/2354/2354-preview.mp3',
    'Bright bell':
        'https://assets.mixkit.co/active_storage/sfx/2357/2357-preview.mp3',
    'Gentle wave':
        'https://assets.mixkit.co/active_storage/sfx/2870/2870-preview.mp3',
  };

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(String sound) async {
    if (sound == 'Vibrate only') return;

    if (_playingSound == sound) {
      await _audioPlayer.stop();
      setState(() => _playingSound = null);
    } else {
      final assetPath = soundAssets[sound];
      if (assetPath != null) {
        try {
          await _audioPlayer.stop();
          await _audioPlayer.play(UrlSource(assetPath));
          setState(() => _playingSound = sound);

          _audioPlayer.onPlayerComplete.listen((_) {
            if (mounted) {
              setState(() => _playingSound = null);
            }
          });
        } catch (e) {
          // Handle audio playback errors
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Could not play sound. Check internet connection.'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder sound',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            for (final sound in soundOptions)
              _buildSoundOption(
                context: context,
                sound: sound,
                selected: sound == widget.currentSound,
                isPlaying: sound == _playingSound,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption({
    required BuildContext context,
    required String sound,
    required bool selected,
    required bool isPlaying,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canPlay = sound != 'Vibrate only';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () {
          context.read<SettingsBloc>().add(SetReminderSound(sound));
          Navigator.of(context).pop();
        },
        leading: Icon(
          sound == 'Vibrate only'
              ? Icons.vibration_rounded
              : Icons.music_note_rounded,
          color: colorScheme.primary,
        ),
        title: Text(
          sound,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          sound == 'Vibrate only'
              ? 'Silent alert with vibration'
              : 'Play this tone for reminders',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canPlay)
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: colorScheme.primary,
                ),
                onPressed: () => _toggleSound(sound),
              ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _optionTile({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    color: colorScheme.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : Icon(Icons.circle_outlined,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
    ),
  );
}

Widget _action(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: NeumorphicButton(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
        ],
      ),
    ),
  );
}
