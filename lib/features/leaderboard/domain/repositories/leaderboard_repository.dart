import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard();
  Future<Either<Failure, LeaderboardEntry>> getUserRank(String userId);
}
