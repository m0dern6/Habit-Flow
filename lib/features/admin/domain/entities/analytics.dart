import 'package:equatable/equatable.dart';

class UserAnalytics extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final List<UserGrowthData> userGrowthData;
  final Map<String, int> usersByCountry;
  final double averageSessionDuration;
  final int totalSessions;

  const UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.userGrowthData,
    required this.usersByCountry,
    required this.averageSessionDuration,
    required this.totalSessions,
  });

  UserAnalytics copyWith({
    int? totalUsers,
    int? activeUsers,
    int? newUsersToday,
    int? newUsersThisWeek,
    int? newUsersThisMonth,
    List<UserGrowthData>? userGrowthData,
    Map<String, int>? usersByCountry,
    double? averageSessionDuration,
    int? totalSessions,
  }) {
    return UserAnalytics(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      newUsersToday: newUsersToday ?? this.newUsersToday,
      newUsersThisWeek: newUsersThisWeek ?? this.newUsersThisWeek,
      newUsersThisMonth: newUsersThisMonth ?? this.newUsersThisMonth,
      userGrowthData: userGrowthData ?? this.userGrowthData,
      usersByCountry: usersByCountry ?? this.usersByCountry,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  @override
  List<Object> get props => [
        totalUsers,
        activeUsers,
        newUsersToday,
        newUsersThisWeek,
        newUsersThisMonth,
        userGrowthData,
        usersByCountry,
        averageSessionDuration,
        totalSessions,
      ];
}

class UserGrowthData extends Equatable {
  final DateTime date;
  final int newUsers;
  final int activeUsers;

  const UserGrowthData({
    required this.date,
    required this.newUsers,
    required this.activeUsers,
  });

  @override
  List<Object> get props => [date, newUsers, activeUsers];
}

class HabitAnalytics extends Equatable {
  final int totalHabits;
  final int activeHabits;
  final int completedHabitsToday;
  final double averageCompletionRate;
  final List<HabitCategoryData> habitsByCategory;
  final List<HabitCompletionData> completionTrends;
  final Map<String, int> popularHabits;

  const HabitAnalytics({
    required this.totalHabits,
    required this.activeHabits,
    required this.completedHabitsToday,
    required this.averageCompletionRate,
    required this.habitsByCategory,
    required this.completionTrends,
    required this.popularHabits,
  });

  HabitAnalytics copyWith({
    int? totalHabits,
    int? activeHabits,
    int? completedHabitsToday,
    double? averageCompletionRate,
    List<HabitCategoryData>? habitsByCategory,
    List<HabitCompletionData>? completionTrends,
    Map<String, int>? popularHabits,
  }) {
    return HabitAnalytics(
      totalHabits: totalHabits ?? this.totalHabits,
      activeHabits: activeHabits ?? this.activeHabits,
      completedHabitsToday: completedHabitsToday ?? this.completedHabitsToday,
      averageCompletionRate:
          averageCompletionRate ?? this.averageCompletionRate,
      habitsByCategory: habitsByCategory ?? this.habitsByCategory,
      completionTrends: completionTrends ?? this.completionTrends,
      popularHabits: popularHabits ?? this.popularHabits,
    );
  }

  @override
  List<Object> get props => [
        totalHabits,
        activeHabits,
        completedHabitsToday,
        averageCompletionRate,
        habitsByCategory,
        completionTrends,
        popularHabits,
      ];
}

class HabitCategoryData extends Equatable {
  final String category;
  final int count;
  final double completionRate;

  const HabitCategoryData({
    required this.category,
    required this.count,
    required this.completionRate,
  });

  @override
  List<Object> get props => [category, count, completionRate];
}

class HabitCompletionData extends Equatable {
  final DateTime date;
  final int totalCompletions;
  final double completionRate;

  const HabitCompletionData({
    required this.date,
    required this.totalCompletions,
    required this.completionRate,
  });

  @override
  List<Object> get props => [date, totalCompletions, completionRate];
}

class SystemAnalytics extends Equatable {
  final int totalApiCalls;
  final double averageResponseTime;
  final int errorCount;
  final double uptime;
  final Map<String, int> apiEndpointUsage;
  final List<SystemMetric> performanceMetrics;

  const SystemAnalytics({
    required this.totalApiCalls,
    required this.averageResponseTime,
    required this.errorCount,
    required this.uptime,
    required this.apiEndpointUsage,
    required this.performanceMetrics,
  });

  SystemAnalytics copyWith({
    int? totalApiCalls,
    double? averageResponseTime,
    int? errorCount,
    double? uptime,
    Map<String, int>? apiEndpointUsage,
    List<SystemMetric>? performanceMetrics,
  }) {
    return SystemAnalytics(
      totalApiCalls: totalApiCalls ?? this.totalApiCalls,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      errorCount: errorCount ?? this.errorCount,
      uptime: uptime ?? this.uptime,
      apiEndpointUsage: apiEndpointUsage ?? this.apiEndpointUsage,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }

  @override
  List<Object> get props => [
        totalApiCalls,
        averageResponseTime,
        errorCount,
        uptime,
        apiEndpointUsage,
        performanceMetrics,
      ];
}

class SystemMetric extends Equatable {
  final DateTime timestamp;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int activeConnections;

  const SystemMetric({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeConnections,
  });

  @override
  List<Object> get props => [
        timestamp,
        cpuUsage,
        memoryUsage,
        diskUsage,
        activeConnections,
      ];
}
