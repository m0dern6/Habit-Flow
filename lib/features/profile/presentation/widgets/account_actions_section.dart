import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/data_preload.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../auth/domain/entities/account_deletion_status.dart';
import '../../../auth/domain/usecases/cancel_account_deletion.dart';
import '../../../auth/domain/usecases/get_account_deletion_status.dart';
import '../../../auth/domain/usecases/schedule_account_deletion.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../habits/domain/usecases/reset_user_progress.dart';

class AccountActionsSection extends StatefulWidget {
  const AccountActionsSection({super.key});

  @override
  State<AccountActionsSection> createState() => _AccountActionsSectionState();
}

class _AccountActionsSectionState extends State<AccountActionsSection> {
  AccountDeletionStatus? _deletionStatus;
  bool _isResetting = false;
  bool _isHandlingDeletion = false;

  @override
  void initState() {
    super.initState();
    _loadDeletionStatus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDeletionPending = _deletionStatus?.isPending == true;

    return Column(
      children: [
        _buildActionItem(
          context,
          'Reset Progress',
          'Clear all habit history',
          Icons.restore_rounded,
          () => _confirmResetProgress(context),
          destructive: true,
          isBusy: _isResetting,
        ),
        _buildActionItem(
          context,
          'Sign Out',
          'Exit your account',
          Icons.logout_rounded,
          () => _showDialog(
              context, 'Sign Out', 'Are you sure you want to sign out?', () {
            context.read<AuthBloc>().add(AuthSignOutRequested());
          }),
          destructive: true,
        ),
        _buildActionItem(
          context,
          isDeletionPending ? 'Cancel Account Deletion' : 'Delete Account',
          _deletionSubtitle(context),
          Icons.delete_forever_rounded,
          () => _handleDeletionFlow(context, isDeletionPending),
          destructive: true,
          isBusy: _isHandlingDeletion,
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle,
      IconData icon, VoidCallback onTap,
      {bool destructive = false, bool isBusy = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = destructive ? colorScheme.error : colorScheme.onSurface;
    final iconColor =
        destructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        onPressed: isBusy ? null : onTap,
        isEnabled: !isBusy,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
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
            isBusy
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: destructive ? colorScheme.error : iconColor,
                    ),
                  )
                : Icon(Icons.chevron_right_rounded,
                    color: iconColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(title.split(' ')[0],
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _deletionSubtitle(BuildContext context) {
    if (_deletionStatus?.isPending == true &&
        _deletionStatus?.deleteAfter != null) {
      final deleteAt = _deletionStatus!.deleteAfter!;
      final dateText =
          MaterialLocalizations.of(context).formatMediumDate(deleteAt);
      final timeText = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(deleteAt),
      );
      return 'Deletion scheduled for $dateText at $timeText';
    }
    if (_deletionStatus?.isPending == true) {
      return 'Deletion scheduled. Tap to cancel';
    }
    return 'Start 7-day deletion trial';
  }

  Future<void> _loadDeletionStatus() async {
    setState(() => _isHandlingDeletion = true);
    final result = await sl<GetAccountDeletionStatus>()(const NoParams());
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isHandlingDeletion = false);
        _showSnack('Unable to load deletion status: $failure');
      },
      (status) => setState(() {
        _deletionStatus = status;
        _isHandlingDeletion = false;
      }),
    );
  }

  void _confirmResetProgress(BuildContext context) {
    _showDialog(
      context,
      'Reset Progress',
      'This will clear all habit history and streaks. Proceed?',
      () async {
        final userId = context.read<AuthBloc>().state.user?.id;
        if (userId == null || userId.isEmpty) {
          _showSnack('No user found. Please sign in again.');
          return;
        }

        setState(() => _isResetting = true);
        _showBlockingLoader();
        final result = await sl<ResetUserProgress>()(
          ResetUserProgressParams(userId: userId),
        );

        if (!mounted) return;

        result.fold(
          (failure) => _showSnack(failure.toString()),
          (_) => _showSnack('All habit history cleared.'),
        );

        // Reload app data similar to profile save flow
        primeUserData(context, userId: userId, refreshAuth: true);
        if (!mounted) return;
        context.go('/home');

        _hideBlockingLoader();
        setState(() => _isResetting = false);
      },
    );
  }

  void _handleDeletionFlow(BuildContext context, bool isPending) {
    if (isPending) {
      _cancelDeletion(context);
      return;
    }

    _showDialog(
      context,
      'Delete Account',
      'Your account will be scheduled for deletion in 7 days. You can cancel anytime before then. Start the trial?',
      () async {
        setState(() => _isHandlingDeletion = true);

        final result = await sl<ScheduleAccountDeletion>()(
          const ScheduleAccountDeletionParams(),
        );

        if (!mounted) return;

        result.fold(
          (failure) => _showSnack(failure.toString()),
          (status) {
            setState(() => _deletionStatus = status);

            final deleteAfter = status.deleteAfter;
            if (deleteAfter != null) {
              final dateText = MaterialLocalizations.of(context)
                  .formatMediumDate(deleteAfter);
              final timeText = MaterialLocalizations.of(context)
                  .formatTimeOfDay(TimeOfDay.fromDateTime(deleteAfter));
              _showSnack('Deletion scheduled for $dateText at $timeText.');
            } else {
              _showSnack('Deletion scheduled.');
            }
          },
        );

        setState(() => _isHandlingDeletion = false);
      },
    );
  }

  Future<void> _cancelDeletion(BuildContext context) async {
    setState(() => _isHandlingDeletion = true);

    final result = await sl<CancelAccountDeletion>()(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) => _showSnack(failure.toString()),
      (status) {
        setState(() => _deletionStatus = status);
        _showSnack('Account deletion cancelled.');
      },
    );

    setState(() => _isHandlingDeletion = false);
  }

  void _showBlockingLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideBlockingLoader() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
