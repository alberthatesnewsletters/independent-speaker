import 'package:attempt4/model/enums/runner_status.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';

class InfoTab extends HookConsumerWidget {
  const InfoTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDiscId = ref.watch(currentDisciplineId);
    final runners = ref
        .watch(runnerMapProvider)
        .values
        .where((element) => element.discipline.id == currentDiscId)
        .toList();

    runners.sort((a, b) => a.startTime.compareTo(b.startTime));

    // final discipline = ref.watch(disciplineMapProvider)[currentDiscId]!;
    final unfinishedCount = ref
        .watch(runnerMapProvider)
        .values
        .where((element) =>
            element.discipline.id == currentDiscId &&
            (element.status == RunnerStatus.Unknown &&
                !element.finishPunch.isPunched))
        .toList()
        .length;

    return Column(
      children: [
        Text("Runners still in forest: $unfinishedCount"),
        Expanded(
          child: ListView(
            controller: ScrollController(),
            children: [
              for (Runner runner in runners)
                ProviderScope(
                    overrides: [currentRunner.overrideWithValue(runner)],
                    child: const StartItem())
            ],
          ),
        )
      ],
    );
  }
}

class StartItem extends HookConsumerWidget {
  const StartItem({Key? key}) : super(key: key);

  String _formatTime(DateTime toFormat) {
    return (toFormat.hour < 10 ? "0${toFormat.hour}" : "${toFormat.hour}") +
        (toFormat.minute < 10
            ? ":0${toFormat.minute}"
            : ":${toFormat.minute}") +
        (toFormat.second != 0
            ? (toFormat.second < 10
                ? ":0${toFormat.second}"
                : ":${toFormat.second}")
            : "");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(_formatTime(runner.startTime)),
    );
  }
}
