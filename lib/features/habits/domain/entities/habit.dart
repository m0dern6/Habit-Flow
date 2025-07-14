import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String iconCode;
  final String color;
  final DateTime createdAt;
  final DateTime? targetTime;
  final int targetDuration; // in minutes
  final bool isActive;
  final List<String> reminderDays; // ['monday', 'tuesday', etc.]
  final DateTime? reminderTime;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.iconCode,
    required this.color,
    required this.createdAt,
    this.targetTime,
    this.targetDuration = 0,
    this.isActive = true,
    this.reminderDays = const [],
    this.reminderTime,
  });

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? iconCode,
    String? color,
    DateTime? createdAt,
    DateTime? targetTime,
    int? targetDuration,
    bool? isActive,
    List<String>? reminderDays,
    DateTime? reminderTime,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      targetTime: targetTime ?? this.targetTime,
      targetDuration: targetDuration ?? this.targetDuration,
      isActive: isActive ?? this.isActive,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        iconCode,
        color,
        createdAt,
        targetTime,
        targetDuration,
        isActive,
        reminderDays,
        reminderTime,
      ];
}
