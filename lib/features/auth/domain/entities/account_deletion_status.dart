import 'package:equatable/equatable.dart';

class AccountDeletionStatus extends Equatable {
  final bool isPending;
  final DateTime? scheduledAt;
  final DateTime? deleteAfter;
  final DateTime? cancelledAt;

  const AccountDeletionStatus({
    required this.isPending,
    this.scheduledAt,
    this.deleteAfter,
    this.cancelledAt,
  });

  bool get isWithinGracePeriod {
    if (!isPending || deleteAfter == null) return false;
    return deleteAfter!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [isPending, scheduledAt, deleteAfter, cancelledAt];
}
