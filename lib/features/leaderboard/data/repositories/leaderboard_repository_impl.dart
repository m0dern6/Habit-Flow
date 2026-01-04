import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard() async {
    try {
      final leaderboard = await remoteDataSource.getLeaderboard();
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaderboardEntry>> getUserRank(String userId) async {
    try {
      final userRank = await remoteDataSource.getUserRank(userId);
      return Right(userRank);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
