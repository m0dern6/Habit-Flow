import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/leaderboard_update_service.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/usecases/get_user_habits.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/update_habit.dart';
import '../../domain/usecases/create_habit_entry.dart';
import '../../domain/usecases/get_habit_entry_for_date.dart';
import '../../domain/repositories/habit_repository.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetUserHabits getUserHabits;
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final CreateHabitEntry createHabitEntry;
  final GetHabitEntryForDate getHabitEntryForDate;
  final HabitRepository habitRepository;
  final NotificationService notificationService;
  final LeaderboardUpdateService leaderboardUpdateService;

  HabitBloc({
    required this.getUserHabits,
    required this.createHabit,
    required this.updateHabit,
    required this.createHabitEntry,
    required this.getHabitEntryForDate,
    required this.habitRepository,
    required this.notificationService,
    required this.leaderboardUpdateService,
  }) : super(const HabitState()) {
    on<LoadUserHabits>(_onLoadUserHabits);
    on<CreateHabitRequested>(_onCreateHabitRequested);
    on<UpdateHabitRequested>(_onUpdateHabitRequested);
    on<DeleteHabitRequested>(_onDeleteHabitRequested);
    on<ToggleHabitCompletion>(_onToggleHabitCompletion);
    on<LoadHabitEntries>(_onLoadHabitEntries);
    on<LoadHabitStreaks>(_onLoadHabitStreaks);
    on<LoadUserHabitEntries>(_onLoadUserHabitEntries);
  }

  Future<void> _onLoadUserHabits(
    LoadUserHabits event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    final result =
        await getUserHabits(GetUserHabitsParams(userId: event.userId));

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (habits) async {
        // Also fetch entries for today and yesterday to show status and streaks
        final today = DateTime.now();
        final startDate =
            DateTime(today.year, today.month, today.day - 7); // Last 7 days
        final endDate =
            DateTime(today.year, today.month, today.day, 23, 59, 59);

        final entriesResult = await habitRepository.getUserHabitEntries(
          event.userId,
          startDate,
          endDate,
        );

        entriesResult.fold(
          (failure) {
            debugPrint('HabitBloc: Failed to load companion entries: $failure');
            emit(state.copyWith(
              status: HabitStatus.loaded,
              habits: habits,
            ));
          },
          (entries) {
            debugPrint(
                'HabitBloc: Pre-loaded ${entries.length} entries for user');
            emit(state.copyWith(
              status: HabitStatus.loaded,
              habits: habits,
              habitEntries: entries,
            ));
          },
        );
      },
    );
  }

  Future<void> _onCreateHabitRequested(
    CreateHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    final result = await createHabit(CreateHabitParams(habit: event.habit));
    await result.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
          status: HabitStatus.error,
          message: failure.toString(),
        ));
      },
      (habit) async {
        // Schedule notifications if reminder is set
        if (habit.reminderTime != null && habit.reminderDays.isNotEmpty) {
          final weekdays = _convertDaysToWeekdays(habit.reminderDays);
          await notificationService.scheduleHabitReminders(
            habitId: habit.id,
            habitTitle: habit.title,
            reminderTime: habit.reminderTime!,
            weekdays: weekdays,
          );
        }

        final updatedHabits = List<Habit>.from(state.habits)..add(habit);
        emit(state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
        ));
      },
    );
  }

  Future<void> _onUpdateHabitRequested(
    UpdateHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    final result = await updateHabit(UpdateHabitParams(habit: event.habit));
    await result.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
          status: HabitStatus.error,
          message: failure.toString(),
        ));
      },
      (updatedHabit) async {
        // Cancel existing notifications
        await notificationService.cancelHabitReminders(updatedHabit.id);

        // Schedule new notifications if reminder is set
        if (updatedHabit.reminderTime != null &&
            updatedHabit.reminderDays.isNotEmpty) {
          final weekdays = _convertDaysToWeekdays(updatedHabit.reminderDays);
          await notificationService.scheduleHabitReminders(
            habitId: updatedHabit.id,
            habitTitle: updatedHabit.title,
            reminderTime: updatedHabit.reminderTime!,
            weekdays: weekdays,
          );
        }

        final updatedHabits = state.habits
            .map((habit) => habit.id == updatedHabit.id ? updatedHabit : habit)
            .toList();
        emit(state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
        ));
      },
    );
  }

  List<int> _convertDaysToWeekdays(List<String> days) {
    const dayMap = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    return days
        .map((day) => dayMap[day.toLowerCase()])
        .whereType<int>()
        .toList();
  }

  Future<void> _onDeleteHabitRequested(
    DeleteHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    // Cancel notifications for this habit
    await notificationService.cancelHabitReminders(event.habitId);

    final result = await habitRepository.deleteHabit(event.habitId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (_) {
        final updatedHabits =
            state.habits.where((habit) => habit.id != event.habitId).toList();
        emit(state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits,
        ));
      },
    );
  }

  Future<void> _onToggleHabitCompletion(
    ToggleHabitCompletion event,
    Emitter<HabitState> emit,
  ) async {
    debugPrint(
        'HabitBloc: ToggleHabitCompletion event received for habit: ${event.habitId}');
    // Check if entry exists for the date
    final existingEntryResult = await getHabitEntryForDate(
      GetHabitEntryForDateParams(
        habitId: event.habitId,
        date: event.date,
      ),
    );

    await existingEntryResult.fold(
      (failure) async {
        debugPrint('HabitBloc: Failed to get habit entry: $failure');
        // Fallback: try to find it in the local state list first
        final localEntry = state.habitEntries.cast<HabitEntry?>().firstWhere(
            (e) =>
                e!.habitId == event.habitId &&
                e.date.year == event.date.year &&
                e.date.month == event.date.month &&
                e.date.day == event.date.day,
            orElse: () => null);

        if (localEntry != null) {
          debugPrint('HabitBloc: Found entry locally as fallback');
          await _processToggleWithEntry(localEntry, event, emit);
        } else {
          emit(state.copyWith(
            status: HabitStatus.error,
            message: failure.toString(),
          ));
        }
      },
      (existingEntry) async {
        debugPrint(
            'HabitBloc: Existing entry status: ${existingEntry != null ? "Found" : "Not Found"}');
        await _processToggleWithEntry(existingEntry, event, emit);
      },
    );
  }

  Future<void> _processToggleWithEntry(
    HabitEntry? existingEntry,
    ToggleHabitCompletion event,
    Emitter<HabitState> emit,
  ) async {
    if (existingEntry != null) {
      // Update existing entry
      final updatedEntry = existingEntry.copyWith(
        completed: event.completed,
        completedAt: event.completed ? DateTime.now() : null,
      );

      final updateResult = await habitRepository.updateHabitEntry(updatedEntry);
      updateResult.fold(
        (failure) {
          debugPrint('HabitBloc: Update habit entry failed: $failure');
          emit(state.copyWith(
            status: HabitStatus.error,
            message: failure.toString(),
          ));
        },
        (_) {
          debugPrint('HabitBloc: Update habit entry successful');
          // Update local state list
          final updatedEntries = state.habitEntries
              .map((e) => e.id == updatedEntry.id ? updatedEntry : e)
              .toList();

          // Force UI refresh by emitting state with updated list
          emit(state.copyWith(
            status: HabitStatus.loaded,
            habitEntries: updatedEntries,
          ));
          debugPrint(
              'HabitBloc: Emitted state with ${updatedEntries.length} entries');

          // Refresh streaks after completion status changes
          add(LoadHabitStreaks(userId: event.userId));

          // Update leaderboard stats in background
          leaderboardUpdateService.updateUserStats(event.userId);
        },
      );
    } else {
      // Create new entry
      final newEntry = HabitEntry(
        id: const Uuid().v4(),
        habitId: event.habitId,
        userId: event.userId,
        date: event.date,
        completed: event.completed,
        createdAt: DateTime.now(),
        completedAt: event.completed ? DateTime.now() : null,
      );

      final createResult = await createHabitEntry(
        CreateHabitEntryParams(entry: newEntry),
      );
      createResult.fold(
        (failure) {
          debugPrint('HabitBloc: Create habit entry failed: $failure');
          emit(state.copyWith(
            status: HabitStatus.error,
            message: failure.toString(),
          ));
        },
        (_) {
          debugPrint('HabitBloc: Create habit entry successful');
          // Add new entry to local state list
          final updatedEntries = List<HabitEntry>.from(state.habitEntries)
            ..add(newEntry);

          // Force UI refresh
          emit(state.copyWith(
            status: HabitStatus.loaded,
            habitEntries: updatedEntries,
          ));
          debugPrint(
              'HabitBloc: Emitted state with ${updatedEntries.length} entries');

          // Refresh streaks after completion status changes
          add(LoadHabitStreaks(userId: event.userId));

          // Update leaderboard stats in background
          leaderboardUpdateService.updateUserStats(event.userId);
        },
      );
    }
  }

  Future<void> _onLoadHabitEntries(
    LoadHabitEntries event,
    Emitter<HabitState> emit,
  ) async {
    final result = await habitRepository.getHabitEntries(
      event.habitId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) {
        // Don't set error status if habits are already loaded
        // Just log the error and keep empty entries
        print('Failed to load habit entries: ${failure.toString()}');
        emit(state.copyWith(
          habitEntries: <HabitEntry>[], // Empty entries list
        ));
      },
      (entries) => emit(state.copyWith(
        habitEntries: entries,
      )),
    );
  }

  Future<void> _onLoadHabitStreaks(
    LoadHabitStreaks event,
    Emitter<HabitState> emit,
  ) async {
    final result = await habitRepository.getHabitStreaks(event.userId);

    result.fold(
      (failure) {
        // Don't set error status if habits are already loaded
        // Just log the error and keep empty streaks
        print('Failed to load habit streaks: ${failure.toString()}');
        emit(state.copyWith(
          habitStreaks: <String, int>{}, // Empty streaks map
        ));
      },
      (streaks) => emit(state.copyWith(
        habitStreaks: streaks,
      )),
    );
  }

  Future<void> _onLoadUserHabitEntries(
    LoadUserHabitEntries event,
    Emitter<HabitState> emit,
  ) async {
    print('📥 HabitBloc: Loading user habit entries');
    print('User ID: ${event.userId}');
    print('Date range: ${event.startDate} to ${event.endDate}');

    final result = await habitRepository.getUserHabitEntries(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) {
        // Don't set error status if habits are already loaded
        // Just log the error and keep current entries
        print('❌ Failed to load user habit entries: ${failure.toString()}');
      },
      (entries) {
        print('✅ Loaded ${entries.length} entries for analytics period');
        if (entries.isNotEmpty) {
          print('Sample entries:');
          for (var i = 0; i < entries.length && i < 5; i++) {
            final entry = entries[i];
            print(
                '  - ${entry.date.month}/${entry.date.day}: ${entry.completed ? "✓" : "✗"} (Habit ID: ${entry.habitId.substring(0, 8)}...)');
          }
        }
        emit(state.copyWith(
          habitEntries: entries,
        ));
      },
    );
  }
}
