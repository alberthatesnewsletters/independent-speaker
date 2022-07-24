import 'package:attempt4/model/dataclasses/immutable/competition.dart';
import 'package:attempt4/view/base_widget.dart';

import 'backend.dart';
import 'model/dataclasses/immutable/club.dart';
import 'model/enums/runner_status.dart';
import 'package:attempt4/view/settings.dart';
import 'package:attempt4/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/better_listener.dart';
import 'model/dataclasses/immutable/control.dart';
import 'model/dataclasses/immutable/discipline.dart';
import 'model/dataclasses/immutable/runner.dart';
import 'model/enums/sorting.dart';
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

final clubMapProvider =
    StateNotifierProvider<ClubMap, Map<int, Club>>((ref) => ClubMap());

final controlMapProvider =
    StateNotifierProvider<ControlMap, Map<int, Control>>((ref) => ControlMap());

final disciplineMapProvider =
    StateNotifierProvider<DisciplineMap, Map<int, Discipline>>(
        (ref) => DisciplineMap());

final runnerMapProvider =
    StateNotifierProvider<RunnerMap, Map<int, Runner>>((ref) => RunnerMap());

final competitionInfoProvider =
    StateNotifierProvider<CompetitionInfo, Competition>(
        (ref) => CompetitionInfo());

final backendInfoProvider = StateNotifierProvider<BackendInfo, Backend>((ref) {
  throw UnimplementedError();
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
      routes: {
        "/": (context) => const SplashScreen(),
        Settings.routeName: (context) {
          // final backend = ModalRoute.of(context)!.settings.arguments as Backend;

          return const Settings(); // TODO less string reliance, like here
        },
        "basewidget": (context) => const BaseWidget()
      },
    );
  }
}

final currentRunner = Provider<Runner>((ref) => throw UnimplementedError());
final currentDisciplineId = Provider<int>((ref) => throw UnimplementedError());
final currentControlId = Provider<int>((ref) => throw UnimplementedError());

final runnerDisciplineFilter = StateProvider<int>((_) => 1);

final lalala = StateProvider.family<Runner, int>((ref, currentRunnerId) {
  return ref.watch(runnerMapProvider)[currentRunnerId]!;
}); // experiment

final filteredRunners = Provider<List<Runner>>((ref) {
  final filter = ref.watch(runnerDisciplineFilter);
  final runners = ref.watch(runnerMapProvider);

  return runners.values
      .where((runner) => runner.discipline.id == filter)
      .toList();
});
