import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import 'finish_punches.dart';
import 'radio_punches.dart';

class DisciplineTab extends HookConsumerWidget {
  const DisciplineTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(currentDisciplineId);
    final controls = ref.watch(disciplineMapProvider)[discId]!.controls;

    // TODO maybe raise state to handle sorting

    List<Widget> babySpawner() {
      List<Widget> babbies = [];
      for (int controlId in controls.keys) {
        babbies.add(Column(
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: () => ref
                        .read(runnerMapProvider.notifier)
                        .markReadPunchUpdateDiscipline(discId, controlId),
                    child: const Text("Mark all as read")),
                TextButton(
                    onPressed: () => ref
                        .read(disciplineMapProvider.notifier)
                        .toggleControlSorting(discId, controlId),
                    child: const Text("Toggle sorting")),
              ],
            ),
            Expanded(
              child: ProviderScope(
                  overrides: [currentControlId.overrideWithValue(controlId)],
                  child: const RadioPunches()),
            ),
          ],
        ));
      }

      babbies.add(Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () => ref
                      .read(runnerMapProvider.notifier)
                      .markReadFinishUpdateDiscipline(discId),
                  child: const Text("Mark all as read")),
              TextButton(
                  onPressed: () => ref
                      .read(disciplineMapProvider.notifier)
                      .toggleFinishSorting(discId),
                  child: const Text("Toggle sorting")),
            ],
          ),
          const Expanded(
            child: Finishes(),
          ),
        ],
      ));

      return babbies;
    }

    List<Text> adultSpawner() {
      List<Text> mommies = [];
      for (int controlId
          in ref.watch(disciplineMapProvider)[discId]!.controls.keys) {
        final newsCount = ref
            .watch(runnerMapProvider)
            .values
            .where((element) =>
                element.discipline.id == discId &&
                element.radioPunches.containsKey(controlId) &&
                !element.radioPunches[controlId]!.isRead)
            .length;

        mommies.add(Text(
          "${ref.watch(disciplineMapProvider)[discId]!.controls[controlId]!.name}: $newsCount",
          style: const TextStyle(fontSize: 30),
        ));
      }

      // const okStatuses = {RunnerStatus.Ok, RunnerStatus.OkNoTime};

      final newsCount = ref
          .watch(runnerMapProvider)
          .values
          .where((element) =>
              element.discipline.id == discId &&
              element.finishPunch.isPunched &&
              !element.finishPunch.isRead)
          .length;
      mommies.add(
          Text("Finish: $newsCount", style: const TextStyle(fontSize: 30)));
      return mommies;
    }

    return DefaultTabController(
      length: controls.length + 1,
      child: Column(
        children: [
          TabBar(labelColor: Colors.blue, tabs: adultSpawner()),
          Expanded(
            child: TabBarView(
              children: babySpawner(),
            ),
          )
        ],
      ),
    );
  }
}
