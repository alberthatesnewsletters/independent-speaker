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
    List<Text> makeTitles() {
      List<Text> titles = [];

      final allRunners = ref.watch(runnerMapProvider).values;
      int updateCount = 0;
      for (Runner runner in allRunners) {
        if (runner.finishPunch.isPunched && !runner.finishPunch.isRead) {
          updateCount++;
        }
      }
      titles.add(Text(
        "All classes: $updateCount",
        style: const TextStyle(fontSize: 30),
      ));

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
                if (punch.placement! < 4) {
                  tierOneUpdates++;
                } else if (punch.placement! < 11) {
                  tierTwoUpdates++;
                } else {
                  tierThreeUpdates++;
                }
              }
            }
            if (runner.finishPunch.isPunched &&
                !runner.finishPunch.isRead &&
                runner.finishPunch.placement != null) {
              if (runner.finishPunch.placement! < 4) {
                tierOneUpdates++;
              } else if (runner.finishPunch.placement! < 11) {
                tierTwoUpdates++;
              } else {
                tierThreeUpdates++;
              }
            }
          }
        }
        titles.add(Text(
          "${disc.name} || T1: $tierOneUpdates T2: $tierTwoUpdates T3: $tierThreeUpdates",
          style: const TextStyle(fontSize: 30),
        ));
      }
      return titles;
    }

    List<Widget> makeTabs() {
      List<Widget> tabs = [];

      tabs.add(const AllRunnersTab());

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
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("I am happy"),
                ),
                PopupMenuItem<int>(value: 1, child: Text("Subscriptions")),
                PopupMenuItem<int>(value: 2, child: Text("Alerts")),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                print("User is happy");
              } else if (value == 1) {
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
            1,
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
