import 'package:attempt4/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'finish_punches.dart';

class AllRunnersTab extends ConsumerWidget {
  const AllRunnersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRunners = ref
        .watch(runnerMapProvider)
        .values
        .where((element) => element.finishPunch.isPunched)
        .toList();

    final observedRunners = ref
        .watch(runnerMapProvider)
        .values
        .where((element) =>
            element.discipline.id ==
                ref.watch(allDisciplinesTabSettingsNotifier).current &&
            element.finishPunch.isPunched)
        .toList();

    final alsoObservedRunners = ref
        .watch(runnerMapProvider)
        .values
        .where((element) =>
            element.discipline.id ==
                ref.watch(allDisciplinesTabSettingsNotifier).current &&
            !element.finishPunch.isPunched)
        .toList();

    allRunners.sort(
        (a, b) => a.finishPunch.punchedAt.compareTo(b.finishPunch.punchedAt));

    observedRunners.sort((a, b) =>
        a.finishPunch.punchedAfter.compareTo(b.finishPunch.punchedAfter));

    alsoObservedRunners.sort((a, b) => ref
        .watch(currentTimeProvider)
        .time
        .difference(a.startTime)
        .compareTo(
            ref.watch(currentTimeProvider).time.difference(b.startTime)));

    observedRunners.addAll(alsoObservedRunners);

    return Column(
      children: [
        TextButton(
            onPressed: () =>
                ref.read(runnerMapProvider.notifier).markFinishReadAll(),
            child: const Text("Mark all as read")),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    for (final runner in allRunners)
                      ProviderScope(
                          overrides: [currentRunner.overrideWithValue(runner)],
                          child: const AllRunnersFinishItem())
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    for (final runner in observedRunners)
                      ProviderScope(
                          overrides: [currentRunner.overrideWithValue(runner)],
                          child: const AllRunnersStatusItem())
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AllRunnersFinishItem extends ConsumerWidget {
  const AllRunnersFinishItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    void _tapped() {
      ref.read(runnerMapProvider.notifier).toggleFinishUpdateSingle(runner.id);
    }

    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(
                "${runner.finishPunch.placement} : ${runner.name} | ${runner.discipline.name}"),
            subtitle: Text(runner.finishPunch.punchedAfter.toString()),
            tileColor: runner.finishPunch.isRead ? Colors.white : Colors.green,
            onTap: _tapped,
          ),
        ),
        IconButton(
            onPressed: () => ref
                .read(allDisciplinesTabSettingsNotifier.notifier)
                .viewDiscipline(runner.discipline.id),
            icon: const Icon(Icons.arrow_right)),
      ],
    );
  }
}

class AllRunnersStatusItem extends ConsumerWidget {
  const AllRunnersStatusItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    return ListTile(
      title: Text("${runner.finishPunch.placement ?? "R"} : ${runner.name}"),
      subtitle: Text(runner.finishPunch.isPunched
          ? runner.finishPunch.punchedAfter.toString()
          : ref
              .watch(currentTimeProvider)
              .time
              .difference(runner.startTime)
              .toString()),
      tileColor: Colors.white,
    );
  }
}
