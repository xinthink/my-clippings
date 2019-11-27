import 'package:flutter/foundation.dart';

/// Clippings syncing jobs
@immutable
class Job {
  /// Instantiate a [Job].
  ///
  /// With a [total] number of clippings, current number of [succeed] and [failed],
  /// time of creation [createdAt], and an optional [finishedAt] if the job is done.
  const Job({
    this.total = 0,
    this.succeed = 0,
    this.failed = 0,
    this.createdAt,
    this.finishedAt,
  });

  /// Create a [Job] object from a Firestore [doc]ument.
  factory Job.fromDoc(Map<String, dynamic> doc) => Job(
    total: doc['total'] ?? 0,
    succeed: doc['succeed'] ?? 0,
    failed: doc['failed'] ?? 0,
    createdAt: doc['createdAt'],
    finishedAt: doc['finishedAt'],
  );

  final int total;
  final int succeed;
  final int failed;
  final int createdAt;
  final int finishedAt;

  /// Fraction of finished clippings
  double get finishedFraction => total > 0 ? (succeed + failed) / total : 0;

  /// Whether this job is finished
  bool get isFinished => total > 0 && (succeed + failed) >= total;

  /// Duration of the job, in milliseconds, negative if unfinished
  int get duration => (finishedAt ?? 0) - createdAt;
}
