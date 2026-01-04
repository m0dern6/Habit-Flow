import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboard {
  final LeaderboardRepository repository;

  GetLeaderboard(this.repository);

  Future<Either<Failure, List<LeaderboardEntry>>> call() async {
    return await repository.getLeaderboard();
  }
}
