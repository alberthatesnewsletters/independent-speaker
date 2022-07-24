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
      for (final disc in ref
          .watch(disciplineMapProvider)
          .values
          .where((element) => element.isFollowed)) {
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
      body: DefaultTabController(
        length: ref
            .watch(disciplineMapProvider)
            .values
            .where((element) => element.isFollowed)
            .length,
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
