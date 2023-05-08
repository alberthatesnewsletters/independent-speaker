import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PLEASE TELL ME THERE WAS AN EASIER WAY

@immutable
class CurrentTime {
  const CurrentTime({required this.time});

  final DateTime time;
}

class CurrentTimeNotifier extends StateNotifier<CurrentTime> {
  CurrentTimeNotifier([CurrentTime? initialTime])
      : super(initialTime ?? CurrentTime(time: DateTime.now()));

  void update(DateTime newTime) {
    state = CurrentTime(time: newTime);
  }
}
