import 'package:attempt4/model/dataclasses/immutable/all_disciplines_settings.dart';
import 'package:attempt4/model/dataclasses/immutable/competition.dart';
import 'package:attempt4/model/dataclasses/immutable/current_time.dart';
import 'package:attempt4/model/dataclasses/immutable/update_tier.dart';
import 'package:attempt4/view/base_widget.dart';
import 'package:attempt4/view/update_settings.dart';
import 'package:flutter/scheduler.dart';

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

final currentTimeProvider =
    StateNotifierProvider<CurrentTimeNotifier, CurrentTime>(
        (ref) => CurrentTimeNotifier());

final updateTierNotifier =
    StateNotifierProvider<UpdateTierNotifier, UpdateTier>(
        (ref) => UpdateTierNotifier());

final allDisciplinesTabSettingsNotifier =
    StateNotifierProvider<AllDisciplinesTabSettings, AllDisciplinesTab>(
        (ref) => AllDisciplinesTabSettings());

// final backendInfoProvider = StateNotifierProvider<BackendInfo, Backend>((ref) {
//   throw UnimplementedError();
// });

void updateTime(WidgetRef ref) async {
  while (true) {
    ref.read(currentTimeProvider.notifier).update(DateTime.now());
    await Future.delayed(const Duration(seconds: 1));
  }
}

Future<void> main() async {
  Utils.serverIP = "192.168.1.139";
  Utils.serverPort = "2009";
  Utils.updateWaitMs = 3000;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    updateTime(ref);
    super.initState();
  }

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
        UpdateSettings.routeName: (context) {
          return const UpdateSettings();
        },
        "basewidget": (context) => const BaseWidget()
      },
    );
  }
}

final currentRunner = Provider<Runner>((ref) => throw UnimplementedError());
final currentDisciplineId = Provider<int>((ref) => throw UnimplementedError());
final currentControlId = Provider<int>((ref) => throw UnimplementedError());
final currentForewarnIsFinish =
    Provider<bool>((ref) => throw UnimplementedError());

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
