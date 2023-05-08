import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';
import '../model/enums/sorting.dart';

class RadioPunches extends HookConsumerWidget {
  const RadioPunches({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(currentDisciplineId);
    final controlId = ref.watch(currentControlId);

    final runners = ref
        .watch(runnerMapProvider)
        .values
        .where((runner) =>
            runner.discipline.id == discId &&
            runner.radioPunches.containsKey(controlId))
        .toList();

    final sorting =
        ref.watch(disciplineMapProvider)[discId]!.controls[controlId]!.sorting;

    if (sorting == Sorting.NewestFirst) {
      runners.sort((a, b) => a.radioPunches[controlId]!.punchedAt
          .compareTo(b.radioPunches[controlId]!.punchedAt));
    } else {
      runners.sort((a, b) => a.radioPunches[controlId]!.punchedAfter
          .compareTo(b.radioPunches[controlId]!.punchedAfter));
    }

    return ListView(
      controller: ScrollController(),
      children: [
        for (Runner runner in runners)
          ProviderScope(
              overrides: [currentRunner.overrideWithValue(runner)],
              child: const RunnerPunchItem())
      ],
    );
  }
}

class RunnerPunchItem extends HookConsumerWidget {
  const RunnerPunchItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);
    final controlId = ref.watch(currentControlId);

    void _tapped() {
      ref
          .read(runnerMapProvider.notifier)
          .toggleControlUpdateSingle(runner.id, controlId);
    }

    return ListTile(
      title:
          Text("${runner.radioPunches[controlId]!.placement} : ${runner.name}"),
      subtitle: Text(runner.radioPunches[controlId]!.punchedAfter.toString()),
      tileColor:
          runner.radioPunches[controlId]!.isRead ? Colors.white : Colors.green,
      onTap: _tapped,
    );
  }
}
