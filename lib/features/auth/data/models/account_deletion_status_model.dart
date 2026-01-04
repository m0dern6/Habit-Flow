import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_deletion_status.dart';

class AccountDeletionStatusModel extends AccountDeletionStatus {
  const AccountDeletionStatusModel({
    required super.isPending,
    super.scheduledAt,
    super.deleteAfter,
    super.cancelledAt,
  });

  factory AccountDeletionStatusModel.fromFirestore(Map<String, dynamic>? data) {
    final scheduledAt = (data?['deletionScheduledAt'] as Timestamp?)?.toDate();
    final deleteAfter = (data?['deletionExecuteAt'] as Timestamp?)?.toDate();
    final cancelledAt = (data?['deletionCancelledAt'] as Timestamp?)?.toDate();
    final status = data?['deletionStatus'] as String?;

    return AccountDeletionStatusModel(
      isPending: status == 'pending',
      scheduledAt: scheduledAt,
      deleteAfter: deleteAfter,
      cancelledAt: cancelledAt,
    );
  }
}
