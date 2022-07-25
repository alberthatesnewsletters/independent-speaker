import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';
import '../model/enums/sorting.dart';

class Forewarn extends HookConsumerWidget {
  const Forewarn({Key? key}) : super(key: key);

  String _formatTime(Duration toFormat) {
    if (toFormat.inHours > 3) {
      return ">3h";
    } else if (toFormat.isNegative) {
      return "-";
    } else {
      int seconds = toFormat.inSeconds;
      final hours = seconds ~/ 3600;
      seconds -= hours * 3600;
      final minutes = seconds ~/ 60;
      seconds -= minutes * 60;

      String toReturn = "";

      if (hours > 0) {
        toReturn += "0$hours:";
      }

      if (minutes > 0) {
        toReturn += "$minutes:";
      } else {
        toReturn += "0:";
      }

      if (seconds == 0) {
        toReturn += "00";
      } else if (seconds < 10) {
        toReturn += "0$seconds";
      } else {
        toReturn += seconds.toString();
      }

      return toReturn;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(_formatTime(
          ref.watch(currentTimeProvider).time.difference(runner.startTime))),
    );
  }
}
