import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/habits/presentation/bloc/habit_bloc.dart';
import '../../features/habits/presentation/bloc/habit_event.dart';

/// Fire off all startup data loads for the signed-in user.
void primeUserData(BuildContext context,
    {String? userId, bool refreshAuth = false}) {
  final resolvedUserId =
      userId ?? context.read<AuthBloc>().state.user?.id ?? '';
  if (resolvedUserId.isEmpty) return;

  if (refreshAuth) {
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  final habitBloc = context.read<HabitBloc>();
  habitBloc.add(LoadUserHabits(userId: resolvedUserId));
  habitBloc.add(LoadHabitStreaks(userId: resolvedUserId));
}
