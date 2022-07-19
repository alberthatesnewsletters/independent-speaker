import 'package:flutter/foundation.dart' show immutable;

import 'punch_status.dart';

@immutable
class FinishStatus extends PunchStatus {
  const FinishStatus(
      {required this.isPunched,
      required super.punchedAt,
      required super.punchedAfter,
      required super.receivedAt,
      required super.isRead});

  final bool isPunched;

  @override
  FinishStatus copyWith(
      {bool? isPunched,
      DateTime? punchedAt,
      Duration? punchedAfter,
      bool? isRead}) {
    if (punchedAt != null || punchedAfter != null) {
      isRead = false;
    }

    return FinishStatus(
        isPunched: isPunched ?? this.isPunched,
        punchedAt: punchedAt ?? this.punchedAt,
        punchedAfter: punchedAfter ?? this.punchedAfter,
        receivedAt: (isRead != null && !isRead) ? DateTime.now() : receivedAt,
        isRead: isRead ?? this.isRead);
  }
}
