import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';
import '../model/enums/sorting.dart';

class Finishes extends HookConsumerWidget {
  const Finishes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(currentDisciplineId);
    // const okStatuses = {RunnerStatus.Ok, RunnerStatus.OkNoTime};

    final runners = ref
        .watch(runnerMapProvider)
        .values
        .where((runner) =>
            runner.discipline.id == discId && runner.finishPunch.isPunched)
        .toList();

    final sorting = ref.watch(disciplineMapProvider)[discId]!.finishSorting;

    if (sorting == Sorting.NewestFirst) {
      runners.sort(
          (a, b) => a.finishPunch.punchedAt.compareTo(b.finishPunch.punchedAt));
    } else {
      runners.sort((a, b) =>
          a.finishPunch.punchedAfter.compareTo(b.finishPunch.punchedAfter));
    }

    return ListView(
      controller: ScrollController(),
      children: [
        for (Runner runner in runners)
          ProviderScope(
              overrides: [currentRunner.overrideWithValue(runner)],
              child: const RunnerFinishItem())
      ],
    );
  }
}

class RunnerFinishItem extends HookConsumerWidget {
  const RunnerFinishItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    void _tapped() {
      ref.read(runnerMapProvider.notifier).toggleFinishUpdateSingle(runner.id);
    }

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(runner.finishPunch.punchedAfter.toString()),
      tileColor: runner.finishPunch.isRead ? Colors.white : Colors.green,
      onTap: _tapped,
    );
  }
}
