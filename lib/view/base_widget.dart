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
      for (Discipline disc in ref.watch(disciplineMapProvider).values) {
        int updateCount = 0;
        for (Runner runner in ref.watch(runnerMapProvider).values) {
          if (runner.discipline.id == disc.id) {
            for (final punch in runner.radioPunches.values) {
              if (!punch.isRead) {
                updateCount++;
              }
            }
            if (runner.finishPunch.isPunched && !runner.finishPunch.isRead) {
              updateCount++;
            }
          }
        }
        titles.add(Text(
          "${disc.name}: $updateCount",
          style: const TextStyle(fontSize: 30),
        ));
      }
      return titles;
    }

    List<Widget> makeTabs() {
      List<Widget> tabs = [];

      for (int discId in ref.watch(disciplineMapProvider).keys) {
        tabs.add(ProviderScope(
            overrides: [currentDisciplineId.overrideWithValue(discId)],
            child: const DisciplineTab()));
      }

      return tabs;
    }

    return DefaultTabController(
      length: ref.watch(disciplineMapProvider).length,
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
    );
  }
}
