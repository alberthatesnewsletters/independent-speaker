import 'package:attempt4/model/dataclasses/immutable/club.dart';
import 'package:attempt4/model/enums/runner_status.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/better_listener.dart';
import 'model/dataclasses/immutable/control.dart';
import 'model/dataclasses/immutable/discipline.dart';
import 'model/dataclasses/immutable/runner.dart';
import 'model/remotes/meos/connection.dart';
import 'model/remotes/meos/reader.dart';
import 'utils.dart';

// Future<void> main() async {
//   Utils.serverIP = "192.168.1.139";
//   Utils.serverPort = "2009";
//   Utils.updateWaitMs = 3000;
//   final conn = MeOSconnection();
//   final listener = CompetitionListener();
//   final reader = MeOSreader(conn, listener);
//   await reader.run();
//   listener.printAll();
//   //runApp(const MyApp());
// }

final clubMapProvider = StateNotifierProvider<ClubMap, Map<int, Club>>((ref) {
  return ClubMap();
});

final controlMapProvider =
    StateNotifierProvider<ControlMap, Map<int, Control>>((ref) {
  return ControlMap();
});

final disciplineMapProvider =
    StateNotifierProvider<DisciplineMap, Map<int, Discipline>>((ref) {
  return DisciplineMap();
});

final runnerMapProvider =
    StateNotifierProvider<RunnerMap, Map<int, Runner>>((ref) {
  return RunnerMap();
});

Future<void> main() async {
  Utils.serverIP = "192.168.1.139";
  Utils.serverPort = "2009";
  Utils.updateWaitMs = 3000;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(body: TestWidget()),
    );
  }
}

final _currentRunner = Provider<Runner>((ref) => throw UnimplementedError());
final _currentDisciplineId = Provider<int>((ref) => throw UnimplementedError());
final _currentControlId = Provider<int>((ref) => throw UnimplementedError());

final runnerDisciplineFilter = StateProvider<int>((_) => 1);

final filteredRunners = Provider<List<Runner>>((ref) {
  final filter = ref.watch(runnerDisciplineFilter);
  final runners = ref.watch(runnerMapProvider);

  return runners.values
      .where((runner) => runner.discipline.id == filter)
      .toList();
});

class TestWidget extends HookConsumerWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = MeOSconnection();
    final listener = BetterListener(clubMapProvider, controlMapProvider,
        disciplineMapProvider, runnerMapProvider, ref);
    final reader = MeOSreader(conn, listener);
    reader.run();
    //return const Text("Hello world!");

    return const TestierWidget();
  }
}

class TestierWidget extends HookConsumerWidget {
  const TestierWidget({Key? key}) : super(key: key);

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

    return DefaultTabController(
      length: ref.watch(disciplineMapProvider).length,
      child: Column(
        children: [
          TabBar(labelColor: Colors.blue, tabs: makeTitles()),
          Expanded(
            child: TabBarView(
              children: [
                for (int discId in ref.watch(disciplineMapProvider).keys)
                  ProviderScope(overrides: [
                    _currentDisciplineId.overrideWithValue(discId)
                  ], child: const DisciplineTab())
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DisciplineTab extends HookConsumerWidget {
  const DisciplineTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(_currentDisciplineId);
    final controls = ref.watch(disciplineMapProvider)[discId]!.controls;

    List<Widget> babySpawner() {
      List<Widget> babbies = [];
      for (int controlId in controls) {
        babbies.add(Column(
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: () => ref
                        .read(runnerMapProvider.notifier)
                        .markReadPunchUpdateDiscipline(discId, controlId),
                    child: const Text("Mark all as read"))
              ],
            ),
            Expanded(
              child: ProviderScope(
                  overrides: [_currentControlId.overrideWithValue(controlId)],
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
                  child: const Text("Mark all as read"))
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
          in ref.watch(disciplineMapProvider)[discId]!.controls) {
        final newsCount = ref
            .watch(runnerMapProvider)
            .values
            .where((element) =>
                element.discipline.id == discId &&
                element.radioPunches.containsKey(controlId) &&
                !element.radioPunches[controlId]!.isRead)
            .length;

        mommies.add(Text(
          "$controlId: $newsCount",
          style: const TextStyle(fontSize: 30),
        ));
      }
      mommies.add(const Text("Finish", style: TextStyle(fontSize: 30)));
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

class RadioPunches extends HookConsumerWidget {
  const RadioPunches({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(_currentDisciplineId);
    final controlId = ref.watch(_currentControlId);

    final runners = ref
        .watch(runnerMapProvider)
        .values
        .where((runner) =>
            runner.discipline.id == discId &&
            runner.radioPunches.containsKey(controlId))
        .toList();

    runners.sort((a, b) => a.radioPunches[controlId]!.punchedAfter
        .compareTo(b.radioPunches[controlId]!.punchedAfter));

    return ListView(
      controller: ScrollController(),
      children: [
        for (Runner runner in runners)
          ProviderScope(
              overrides: [_currentRunner.overrideWithValue(runner)],
              child: const RunnerPunchItem())
      ],
    );
  }
}

class Finishes extends HookConsumerWidget {
  const Finishes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discId = ref.watch(_currentDisciplineId);

    final runners = ref
        .watch(runnerMapProvider)
        .values
        .where((runner) =>
            runner.discipline.id == discId && runner.finishPunch.isPunched)
        .toList();

    runners.sort((a, b) =>
        a.finishPunch.punchedAfter.compareTo(b.finishPunch.punchedAfter));

    return ListView(
      controller: ScrollController(),
      children: [
        for (Runner runner in runners)
          ProviderScope(
              overrides: [_currentRunner.overrideWithValue(runner)],
              child: const RunnerFinishItem())
      ],
    );
  }
}

class RunnerPunchItem extends HookConsumerWidget {
  const RunnerPunchItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(_currentRunner);
    final controlId = ref.watch(_currentControlId);

    void _tapped() {
      ref
          .read(runnerMapProvider.notifier)
          .toggleControlUpdateSingle(runner.id, controlId);
    }

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(runner.radioPunches[controlId]!.punchedAfter.toString()),
      tileColor:
          runner.radioPunches[controlId]!.isRead ? Colors.white : Colors.green,
      onTap: _tapped,
    );
  }
}

class RunnerFinishItem extends HookConsumerWidget {
  const RunnerFinishItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(_currentRunner);

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
