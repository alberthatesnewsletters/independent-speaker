import 'package:flutter/foundation.dart' show immutable;

@immutable
class PunchStatus {
  const PunchStatus(
      {required this.punchedAt,
      required this.punchedAfter,
      required this.receivedAt,
      required this.isRead});

  final DateTime punchedAt;
  final Duration punchedAfter;
  final DateTime receivedAt;
  final bool isRead;

  bool hasSameTimes(PunchStatus other) {
    return (punchedAt == other.punchedAt && punchedAfter == other.punchedAfter);
  }

  PunchStatus copyWith(
      {DateTime? punchedAt, Duration? punchedAfter, bool? isRead}) {
    if (punchedAt != null || punchedAfter != null) {
      isRead = false;
    }

    return PunchStatus(
        punchedAt: punchedAt ?? this.punchedAt,
        punchedAfter: punchedAfter ?? this.punchedAfter,
        receivedAt: (isRead != null && !isRead) ? DateTime.now() : receivedAt,
        isRead: isRead ?? this.isRead);
  }
}
