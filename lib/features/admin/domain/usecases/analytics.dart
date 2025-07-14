import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analytics.dart';
import '../repositories/admin_repository.dart';

class GetUserAnalytics implements UseCase<UserAnalytics, GetAnalyticsParams> {
  final AdminRepository repository;

  GetUserAnalytics(this.repository);

  @override
  Future<Either<Failure, UserAnalytics>> call(GetAnalyticsParams params) async {
    return await repository.getUserAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetHabitAnalytics implements UseCase<HabitAnalytics, GetAnalyticsParams> {
  final AdminRepository repository;

  GetHabitAnalytics(this.repository);

  @override
  Future<Either<Failure, HabitAnalytics>> call(
      GetAnalyticsParams params) async {
    return await repository.getHabitAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetSystemAnalytics
    implements UseCase<SystemAnalytics, GetAnalyticsParams> {
  final AdminRepository repository;

  GetSystemAnalytics(this.repository);

  @override
  Future<Either<Failure, SystemAnalytics>> call(
      GetAnalyticsParams params) async {
    return await repository.getSystemAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAnalyticsParams({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ExportUsersData implements UseCase<String, ExportDataParams> {
  final AdminRepository repository;

  ExportUsersData(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportDataParams params) async {
    return await repository.exportUsersData(
      startDate: params.startDate,
      endDate: params.endDate,
      format: params.format,
    );
  }
}

class ExportHabitsData implements UseCase<String, ExportDataParams> {
  final AdminRepository repository;

  ExportHabitsData(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportDataParams params) async {
    return await repository.exportHabitsData(
      startDate: params.startDate,
      endDate: params.endDate,
      format: params.format,
    );
  }
}

class ExportDataParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String format;

  const ExportDataParams({
    this.startDate,
    this.endDate,
    this.format = 'csv',
  });

  @override
  List<Object?> get props => [startDate, endDate, format];
}
