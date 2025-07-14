import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
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

  HabitBloc({
    required this.getUserHabits,
    required this.createHabit,
    required this.updateHabit,
    required this.createHabitEntry,
    required this.getHabitEntryForDate,
    required this.habitRepository,
  }) : super(const HabitState()) {
    on<LoadUserHabits>(_onLoadUserHabits);
    on<CreateHabitRequested>(_onCreateHabitRequested);
    on<UpdateHabitRequested>(_onUpdateHabitRequested);
    on<DeleteHabitRequested>(_onDeleteHabitRequested);
    on<ToggleHabitCompletion>(_onToggleHabitCompletion);
    on<LoadHabitEntries>(_onLoadHabitEntries);
    on<LoadHabitStreaks>(_onLoadHabitStreaks);
  }

  Future<void> _onLoadUserHabits(
    LoadUserHabits event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    final result =
        await getUserHabits(GetUserHabitsParams(userId: event.userId));
    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (habits) => emit(state.copyWith(
        status: HabitStatus.loaded,
        habits: habits,
      )),
    );
  }

  Future<void> _onCreateHabitRequested(
    CreateHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

    final result = await createHabit(CreateHabitParams(habit: event.habit));
    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (habit) {
        final updatedHabits = List<dynamic>.from(state.habits)..add(habit);
        emit(state.copyWith(
          status: HabitStatus.loaded,
          habits: updatedHabits.cast(),
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
    result.fold(
      (failure) => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (updatedHabit) {
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

  Future<void> _onDeleteHabitRequested(
    DeleteHabitRequested event,
    Emitter<HabitState> emit,
  ) async {
    emit(state.copyWith(status: HabitStatus.loading));

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
    // Check if entry exists for the date
    final existingEntryResult = await getHabitEntryForDate(
      GetHabitEntryForDateParams(
        habitId: event.habitId,
        date: event.date,
      ),
    );

    existingEntryResult.fold(
      (failure) => emit(state.copyWith(
        status: HabitStatus.error,
        message: failure.toString(),
      )),
      (existingEntry) async {
        if (existingEntry != null) {
          // Update existing entry
          final updatedEntry = existingEntry.copyWith(
            completed: event.completed,
            completedAt: event.completed ? DateTime.now() : null,
          );

          final updateResult =
              await habitRepository.updateHabitEntry(updatedEntry);
          updateResult.fold(
            (failure) => emit(state.copyWith(
              status: HabitStatus.error,
              message: failure.toString(),
            )),
            (_) => emit(state.copyWith(status: HabitStatus.loaded)),
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
            (failure) => emit(state.copyWith(
              status: HabitStatus.error,
              message: failure.toString(),
            )),
            (_) => emit(state.copyWith(status: HabitStatus.loaded)),
          );
        }
      },
    );
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
}
