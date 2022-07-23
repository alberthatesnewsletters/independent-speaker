// Albert 2022-07-11: "maybe I won't need this class"

import 'package:attempt4/main.dart';
import 'package:attempt4/model/competition.dart';
import 'package:attempt4/model/handlers/club_handler.dart';
import 'package:attempt4/model/handlers/control_handler.dart';
import 'package:attempt4/model/handlers/discipline_handler.dart';
import 'package:attempt4/model/handlers/runner_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dataclasses/immutable/club.dart';
import 'dataclasses/immutable/control.dart';
import 'dataclasses/immutable/discipline.dart';
import 'dataclasses/immutable/runner.dart';
import 'dataclasses/remote/club.dart';
import 'dataclasses/remote/control.dart';
import 'dataclasses/remote/discipline.dart';
import 'dataclasses/remote/runner.dart';

class BetterListener {
  BetterListener(
      {required this.clubs,
      required this.controls,
      required this.disciplines,
      required this.runners,
      required this.competition,
      required this.ref}) {
    _generateHandlers();
  }

  final StateNotifierProvider<ClubMap, Map<int, Club>> clubs;
  final StateNotifierProvider<ControlMap, Map<int, Control>> controls;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> runners;
  final Competition competition;
  final WidgetRef ref;

  late final ClubHandler clubHandler;
  late final ControlHandler controlHandler;
  late final DisciplineHandler disciplineHandler;
  late final RunnerHandler runnerHandler;

  void _generateHandlers() {
    clubHandler = ClubHandler(ref, clubs, runners);
    controlHandler = ControlHandler(controls, disciplines, ref);
    disciplineHandler = DisciplineHandler(controls, disciplines, runners, ref);
    runnerHandler =
        RunnerHandler(clubs, disciplines, runners, competition, ref);
  }

  void wipeInfo() {
    ref.read(clubs.notifier).clear();
    ref.read(controls.notifier).clear();
    ref.read(disciplines.notifier).clear();
    ref.read(runners.notifier).clear();
  }

  void processClubs(List<RemoteClub> updates) {
    clubHandler.processClubs(updates);
  }

  void processControls(List<RemoteControl> updates) {
    controlHandler.processControls(updates);
  }

  void processDisciplines(List<RemoteDiscipline> updates) {
    disciplineHandler.processDisciplines(updates);
  }

  void processRunners(List<RemoteRunner> updates) {
    runnerHandler.processRunners(updates);
  }
}
