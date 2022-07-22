// Albert 2022-07-11: "maybe I won't need this class"

import 'package:attempt4/main.dart';
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
  BetterListener(this._clubs, this._controls, this._disciplines, this._runners,
      this._ref) {
    _generateHandlers();
  }

  final StateNotifierProvider<ClubMap, Map<int, Club>> _clubs;
  final StateNotifierProvider<ControlMap, Map<int, Control>> _controls;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
  final WidgetRef _ref;

  late final ClubHandler clubHandler;
  late final ControlHandler controlHandler;
  late final DisciplineHandler disciplineHandler;
  late final RunnerHandler runnerHandler;

  void _generateHandlers() {
    clubHandler = ClubHandler(_ref, _clubs, _runners);
    controlHandler = ControlHandler(_controls, _disciplines, _ref);
    disciplineHandler =
        DisciplineHandler(_controls, _disciplines, _runners, _ref);
    runnerHandler = RunnerHandler(_clubs, _disciplines, _runners, _ref);
  }

  void wipeInfo() {
    _ref.read(_clubs.notifier).clear();
    _ref.read(_controls.notifier).clear();
    _ref.read(_disciplines.notifier).clear();
    _ref.read(_runners.notifier).clear();
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
