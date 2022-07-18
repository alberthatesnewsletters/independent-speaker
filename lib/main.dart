import 'package:attempt4/model/dataclasses/immutable/club.dart';
import 'package:attempt4/model/enums/runner_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Container(child: const TestierWidget());
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
            for (final punch in runner.punches.values) {
              if (!punch.isRead) {
                updateCount++;
              }
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
        babbies.add(ProviderScope(
            overrides: [_currentControlId.overrideWithValue(controlId)],
            child: const RadioPunches()));
      }
      babbies.add(const Finishes());
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
                element.punches.containsKey(controlId) &&
                !element.punches[controlId]!.isRead)
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
            runner.punches.containsKey(controlId))
        .toList();

    runners.sort((a, b) => a.finishedAfter.compareTo(b.finishedAfter)); // TODO

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
            runner.discipline.id == discId &&
            runner.finishedAfter.inMilliseconds.toInt() > 0)
        .toList();

    runners.sort((a, b) => a.finishedAfter.compareTo(b.finishedAfter));

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

    void tapped() {
      ref
          .read(runnerMapProvider.notifier)
          .toggleControlUpdateSingle(runner.id, controlId);
    }

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(runner.punches[controlId]!.punchedAfter.toString()),
      tileColor:
          runner.punches[controlId]!.isRead ? Colors.white : Colors.green,
      onTap: tapped,
    );
  }
}

class RunnerFinishItem extends HookConsumerWidget {
  const RunnerFinishItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(_currentRunner);

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(runner.finishedAfter.toString()),
    );
  }
}

// class YayWidget extends HookConsumerWidget {
//   YayWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final clubs = ref.watch(clubMapProvider).values.toList();
//     final controls = ref.watch(controlMapProvider).values.toList();
//     final disciplines = ref.watch(disciplineMapProvider).values.toList();
//     final runners = ref.watch(runnerMapProvider).values.toList();

//     List<ListTile> allTheThings() {
//       final List<ListTile> things = [];
//       for (Club club in clubs) {
//         things.add(ListTile(
//           title: Text(club.name),
//           subtitle: Text(club.country.toString()),
//         ));
//       }

//       for (Control control in controls) {
//         things.add(ListTile(
//           title: Text(control.name),
//           subtitle: Text(control.id.toString()),
//         ));
//       }

//       for (Discipline discipline in disciplines) {
//         things.add(ListTile(
//           title: Text(discipline.name),
//           subtitle: Text(discipline.id.toString()),
//         ));
//       }

//       for (Runner runner in runners) {
//         things.add(ListTile(
//           title: Text(runner.name),
//           subtitle: Text(runner.club.name),
//         ));
//       }

//       return things;
//     }

//     //return Text(clubs.first.name);

//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             children: allTheThings(),
//           ),
//         ),
//       ],
//     );
//   }
// }
