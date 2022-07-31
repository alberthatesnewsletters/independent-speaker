import 'update_settings.dart';

import 'all_runners_tab.dart';
import 'settings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/discipline.dart';
import '../model/dataclasses/immutable/runner.dart';
import 'discipline_tab.dart';

class BaseWidget extends HookConsumerWidget {
  const BaseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(updateTierNotifier);

    List<Card> makeTitles() {
      List<Card> titles = [];

      final allRunners = ref.watch(runnerMapProvider).values;

      if (ref.watch(allDisciplinesTabSettingsNotifier).trackAll) {
        int updateCount = 0;
        // TODO this is ignoring the settings
        for (Runner runner in allRunners) {
          if (runner.finishPunch.isPunched && !runner.finishPunch.isRead) {
            updateCount++;
          }
        }
        titles.add(Card(
          child: Column(
            children: [
              const Text(
                "All classes",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                updateCount.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
      }

      for (final disc in ref
          .watch(disciplineMapProvider)
          .values
          .where((element) => element.isFollowed)) {
        int tierOneUpdates = 0;
        int tierTwoUpdates = 0;
        int tierThreeUpdates = 0;
        for (Runner runner in ref.watch(runnerMapProvider).values) {
          if (runner.discipline.id == disc.id) {
            for (final punch in runner.radioPunches.values) {
              if (!punch.isRead && punch.placement != null) {
                if (settings.enableTierOne) {
                  if (settings.tierOneLimit == null ||
                      punch.placement! <= settings.tierOneLimit!) {
                    tierOneUpdates++;
                  } else if (settings.enableTierTwo) {
                    if (settings.tierTwoLimit == null ||
                        punch.placement! <= settings.tierTwoLimit!) {
                      tierTwoUpdates++;
                    } else if (settings.enableTierThree &&
                        (settings.tierThreeLimit == null ||
                            punch.placement! <= settings.tierThreeLimit!)) {
                      tierThreeUpdates++;
                    }
                  }
                }
              }
            }
            if (runner.finishPunch.isPunched &&
                !runner.finishPunch.isRead &&
                runner.finishPunch.placement != null) {
              if (settings.enableTierOne) {
                if (settings.tierOneLimit == null ||
                    runner.finishPunch.placement! <= settings.tierOneLimit!) {
                  tierOneUpdates++;
                } else if (settings.enableTierTwo) {
                  if (settings.tierTwoLimit == null ||
                      runner.finishPunch.placement! <= settings.tierTwoLimit!) {
                    tierTwoUpdates++;
                  } else if (settings.enableTierThree &&
                      (settings.tierThreeLimit == null ||
                          runner.finishPunch.placement! <=
                              settings.tierThreeLimit!)) {
                    tierThreeUpdates++;
                  }
                }
              }
            }
          }
        }
        titles.add(Card(
          child: Column(
            children: [
              Text(
                disc.name,
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
      return titles;
    }

    List<Widget> makeTabs() {
      List<Widget> tabs = [];

      if (ref.watch(allDisciplinesTabSettingsNotifier).trackAll) {
        tabs.add(const AllRunnersTab());
      }

      for (final disc in ref.watch(disciplineMapProvider).values.where(
            (element) => element.isFollowed,
          )) {
        tabs.add(ProviderScope(
            overrides: [currentDisciplineId.overrideWithValue(disc.id)],
            child: const DisciplineTab()));
      }

      return tabs;
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "${ref.watch(competitionInfoProvider).name} ${ref.watch(competitionInfoProvider).date}",
          style: const TextStyle(fontSize: 30),
        )),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              // TODO enum instead of ints
              return const [
                PopupMenuItem<int>(value: 1, child: Text("Subscriptions")),
                PopupMenuItem<int>(value: 2, child: Text("Alerts")),
              ];
            },
            onSelected: (value) {
              if (value == 1) {
                Navigator.pushNamed(context, Settings.routeName);
              } else if (value == 2) {
                Navigator.pushNamed(context, UpdateSettings.routeName);
              }
            },
          )
        ],
      ),
      body: DefaultTabController(
        length: ref
                .watch(disciplineMapProvider)
                .values
                .where((element) => element.isFollowed)
                .length +
            (ref.watch(allDisciplinesTabSettingsNotifier).trackAll ? 1 : 0),
        child: Column(
          children: [
            TabBar(labelColor: Colors.blue, tabs: makeTitles()),
            Expanded(
              child: TabBarView(
                children: makeTabs(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
