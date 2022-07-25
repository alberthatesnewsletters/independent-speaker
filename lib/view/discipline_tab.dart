import 'package:attempt4/view/forewarn_tab.dart';
import 'package:attempt4/view/info_tab.dart';
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

      babbies.add(Column(
        children: [
          Expanded(
            child: ProviderScope(
                overrides: [currentDisciplineId.overrideWithValue(discId)],
                child: const InfoTab()),
          ),
        ],
      ));

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
                overrides: [
                  currentControlId.overrideWithValue(controlId),
                  currentForewarnIsFinish.overrideWithValue(false)
                ],
                child: Row(
                  children: const [
                    Expanded(child: RadioPunches()),
                    Expanded(child: ForewarnTab()),
                  ],
                ),
              ),
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
          Expanded(
            child: ProviderScope(
              overrides: [currentForewarnIsFinish.overrideWithValue(true)],
              child: Row(
                children: const [
                  Expanded(child: Finishes()),
                  Expanded(child: ForewarnTab())
                ],
              ),
            ),
          ),
        ],
      ));

      return babbies;
    }

    List<Text> adultSpawner() {
      List<Text> mommies = [];

      mommies.add(const Text(
        "Info",
        style: TextStyle(fontSize: 30),
      ));

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
      length: controls.length + 2,
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
