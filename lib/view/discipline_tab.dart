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
    final updateSettings = ref.watch(updateTierNotifier);

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

    List<Card> adultSpawner() {
      List<Card> mommies = [];

      mommies.add(const Card(
        child: Text(
          "Info",
          style: TextStyle(fontSize: 30),
        ),
      ));

      for (int controlId
          in ref.watch(disciplineMapProvider)[discId]!.controls.keys) {
        int tierOneUpdates = 0;
        int tierTwoUpdates = 0;
        int tierThreeUpdates = 0;

        if (updateSettings.enableTierOne) {
          if (updateSettings.tierOneLimit == null) {
            tierOneUpdates += ref
                .watch(runnerMapProvider)
                .values
                .where((element) =>
                    element.discipline.id == discId &&
                    element.radioPunches.containsKey(controlId) &&
                    !element.radioPunches[controlId]!.isRead)
                .length;
          } else {
            tierOneUpdates += ref
                .watch(runnerMapProvider)
                .values
                .where((element) => element.discipline.id == discId &&
                        element.radioPunches.containsKey(controlId) &&
                        !element.radioPunches[controlId]!.isRead &&
                        element.radioPunches[controlId]!.placement != null
                    ? element.radioPunches[controlId]!.placement! <=
                        updateSettings.tierOneLimit!
                    : false)
                .length;

            if (updateSettings.enableTierTwo) {
              if (updateSettings.tierTwoLimit == null) {
                tierTwoUpdates += ref
                    .watch(runnerMapProvider)
                    .values
                    .where((element) => element.discipline.id == discId &&
                            element.radioPunches.containsKey(controlId) &&
                            !element.radioPunches[controlId]!.isRead &&
                            element.radioPunches[controlId]!.placement != null
                        ? element.radioPunches[controlId]!.placement! >
                            updateSettings.tierOneLimit!
                        : false)
                    .length;
              } else {
                tierTwoUpdates += ref
                    .watch(runnerMapProvider)
                    .values
                    .where((element) => element.discipline.id == discId &&
                            element.radioPunches.containsKey(controlId) &&
                            !element.radioPunches[controlId]!.isRead &&
                            element.radioPunches[controlId]!.placement != null
                        ? (element.radioPunches[controlId]!.placement! >
                                updateSettings.tierOneLimit! &&
                            element.radioPunches[controlId]!.placement! <=
                                updateSettings.tierTwoLimit!)
                        : false)
                    .length;
                if (updateSettings.enableTierThree) {
                  if (updateSettings.tierThreeLimit == null) {
                    tierThreeUpdates += ref
                        .watch(runnerMapProvider)
                        .values
                        .where((element) => element.discipline.id == discId &&
                                element.radioPunches.containsKey(controlId) &&
                                !element.radioPunches[controlId]!.isRead &&
                                element.radioPunches[controlId]!.placement !=
                                    null
                            ? element.radioPunches[controlId]!.placement! >
                                updateSettings.tierTwoLimit!
                            : false)
                        .length;
                  } else {
                    tierThreeUpdates += ref
                        .watch(runnerMapProvider)
                        .values
                        .where((element) => element.discipline.id == discId &&
                                element.radioPunches.containsKey(controlId) &&
                                !element.radioPunches[controlId]!.isRead &&
                                element.radioPunches[controlId]!.placement !=
                                    null
                            ? (element.radioPunches[controlId]!.placement! >
                                    updateSettings.tierTwoLimit! &&
                                element.radioPunches[controlId]!.placement! <=
                                    updateSettings.tierThreeLimit!)
                            : false)
                        .length;
                  }
                }
              }
            }
          }
        }

        mommies.add(Card(
          child: Column(
            children: [
              Text(
                ref
                    .watch(disciplineMapProvider)[discId]!
                    .controls[controlId]!
                    .name,
                style: const TextStyle(fontSize: 30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    tierOneUpdates == 0 ? "" : tierOneUpdates.toString(),
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  Text(tierTwoUpdates == 0 ? "" : tierTwoUpdates.toString(),
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(tierThreeUpdates == 0 ? "" : tierThreeUpdates.toString(),
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
        ));
      }

      int tierOneUpdates = 0;
      int tierTwoUpdates = 0;
      int tierThreeUpdates = 0;

      if (updateSettings.enableTierOne) {
        if (updateSettings.tierOneLimit == null) {
          tierOneUpdates += ref
              .watch(runnerMapProvider)
              .values
              .where((element) =>
                  element.discipline.id == discId &&
                  element.finishPunch.isPunched &&
                  !element.finishPunch.isRead)
              .length;
        } else {
          tierOneUpdates += ref
              .watch(runnerMapProvider)
              .values
              .where((element) => element.discipline.id == discId &&
                      element.finishPunch.isPunched &&
                      !element.finishPunch.isRead &&
                      element.finishPunch.placement != null
                  ? element.finishPunch.placement! <=
                      updateSettings.tierOneLimit!
                  : false)
              .length;

          if (updateSettings.enableTierTwo) {
            if (updateSettings.tierTwoLimit == null) {
              tierTwoUpdates += ref
                  .watch(runnerMapProvider)
                  .values
                  .where((element) => element.discipline.id == discId &&
                          element.finishPunch.isPunched &&
                          !element.finishPunch.isRead &&
                          element.finishPunch.placement != null
                      ? element.finishPunch.placement! >
                          updateSettings.tierOneLimit!
                      : false)
                  .length;
            } else {
              tierTwoUpdates += ref
                  .watch(runnerMapProvider)
                  .values
                  .where((element) => element.discipline.id == discId &&
                          element.finishPunch.isPunched &&
                          !element.finishPunch.isRead &&
                          element.finishPunch.placement != null
                      ? (element.finishPunch.placement! >
                              updateSettings.tierOneLimit! &&
                          element.finishPunch.placement! <=
                              updateSettings.tierTwoLimit!)
                      : false)
                  .length;
              if (updateSettings.enableTierThree) {
                if (updateSettings.tierThreeLimit == null) {
                  tierThreeUpdates += ref
                      .watch(runnerMapProvider)
                      .values
                      .where((element) => element.discipline.id == discId &&
                              element.finishPunch.isPunched &&
                              !element.finishPunch.isRead &&
                              element.finishPunch.placement != null
                          ? element.finishPunch.placement! >
                              updateSettings.tierTwoLimit!
                          : false)
                      .length;
                } else {
                  tierThreeUpdates += ref
                      .watch(runnerMapProvider)
                      .values
                      .where((element) => element.discipline.id == discId &&
                              element.finishPunch.isPunched &&
                              !element.finishPunch.isRead &&
                              element.finishPunch.placement != null
                          ? (element.finishPunch.placement! >
                                  updateSettings.tierTwoLimit! &&
                              element.finishPunch.placement! <=
                                  updateSettings.tierThreeLimit!)
                          : false)
                      .length;
                }
              }
            }
          }
        }
      }

      mommies.add(Card(
        child: Column(
          children: [
            const Text(
              "Finish",
              style: TextStyle(fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  tierOneUpdates == 0 ? "" : tierOneUpdates.toString(),
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Text(tierTwoUpdates == 0 ? "" : tierTwoUpdates.toString(),
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                Text(tierThreeUpdates == 0 ? "" : tierThreeUpdates.toString(),
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ));

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
