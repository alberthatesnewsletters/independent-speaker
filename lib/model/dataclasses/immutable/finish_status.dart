import 'package:flutter/foundation.dart' show immutable;

import 'punch_status.dart';

@immutable
class FinishStatus extends PunchStatus {
  const FinishStatus(
      {required this.isPunched,
      required super.punchedAt,
      required super.punchedAfter,
      required super.receivedAt,
      required super.placement,
      required super.isRead});

  final bool isPunched;

  @override
  FinishStatus copyWith(
      {bool? isPunched,
      DateTime? punchedAt,
      Duration? punchedAfter,
      bool? isRead,
      int? placement}) {
    if (punchedAt != null || punchedAfter != null) {
      isRead = false;
    }

    return FinishStatus(
        isPunched: isPunched ?? this.isPunched,
        punchedAt: punchedAt ?? this.punchedAt,
        punchedAfter: punchedAfter ?? this.punchedAfter,
        receivedAt: (isRead != null && !isRead) ? DateTime.now() : receivedAt,
        placement: placement ?? this.placement,
        isRead: isRead ?? this.isRead);
  }
}
