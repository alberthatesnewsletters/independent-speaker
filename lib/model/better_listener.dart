// Albert 2022-07-11: "maybe I won't need this class"

import 'package:attempt4/model/dataclasses/immutable/finish_status.dart';

import 'dataclasses/immutable/punch_status.dart';
import 'enums/country.dart';
import 'enums/runner_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'competition.dart';
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
      this._clubs, this._controls, this._disciplines, this._runners, this._ref);

  final StateNotifierProvider<ClubMap, Map<int, Club>> _clubs;
  final StateNotifierProvider<ControlMap, Map<int, Control>> _controls;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
  final WidgetRef _ref;
  final int _batchUpdateThreshold = 3; // number pulled out of my ass
  final DateTime _placeHolderTime = DateTime(2000);

  // TODO divide into four classes

  void wipeInfo() {
    _ref.read(_clubs.notifier).clear();
    _ref.read(_controls.notifier).clear();
    _ref.read(_disciplines.notifier).clear();
    _ref.read(_runners.notifier).clear();
  }

  Club _generateClub(RemoteClub club) {
    return Club(id: club.id, name: club.name, country: club.country);
  }

  void _deleteClub(RemoteClub toDelete) {
    // TODO find relevant runners, give them no club
    _ref.read(_clubs.notifier).remove(toDelete.id);
  }

  void _handleMultipleClubs(List<RemoteClub> updates) {
    final Map<int, Club> toSend = {};
    for (final club in updates) {
      if (club.isDeletion) {
        _deleteClub(club);
      } else if (_ref.read(_clubs).containsKey(club.id)) {
        _updateClub(club);
      } else {
        toSend[club.id] = _generateClub(club);
      }
    }
    _ref.read(_clubs.notifier).batchAdd(toSend);
  }

  void _updateClub(RemoteClub update) {
    final updatedClub = _generateClub(update);
    for (final runner in _ref.read(_runners).values) {
      if (runner.club.id == update.id) {
        _ref.read(_runners.notifier).add(runner.copyWith(club: updatedClub));
      }
    }
    _ref.read(_clubs.notifier).add(updatedClub);
  }

  void _handleSingleClub(RemoteClub update) {
    if (update.isDeletion) {
      _deleteClub(update);
    } else if ((_ref.read(_clubs).containsKey(update.id))) {
      _updateClub(update);
    } else {
      final toSend = _generateClub(update);
      _ref.read(_clubs.notifier).add(toSend);
    }
  }

  void processClubs(List<RemoteClub> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleClubs(updates);
    } else {
      for (final club in updates) {
        _handleSingleClub(club);
      }
    }
  }

  Control _generateControl(RemoteControl control) {
    return Control(id: control.id, name: control.name);
  }

  void _deleteControl(RemoteControl toDelete) {
    for (final discipline in _ref.read(_disciplines).values) {
      if (discipline.controls.contains(toDelete.id)) {
        final newControls = List<int>.from(discipline.controls);
        newControls.remove(toDelete.id);
        _ref
            .read(_disciplines.notifier)
            .add(discipline.copyWith(controls: newControls));
      }
    }
    _ref.read(_controls.notifier).remove(toDelete.id);
  }

  void _handleMultipleControls(List<RemoteControl> updates) {
    final Map<int, Control> toSend = {};
    for (final control in updates) {
      if (control.isDeletion) {
        _deleteControl(control);
      } else if (_ref.read(_controls).containsKey(control.id)) {
        _updateControl(control);
      } else {
        toSend[control.id] = _generateControl(control);
      }
    }
    _ref.read(_controls.notifier).batchAdd(toSend);
  }

  void _updateControl(RemoteControl update) {
    final updatedControl = _generateControl(update);
    // TODO give a shit?
    // for (Discipline discipline in ref.read(disciplines).values) {

    // }
    _ref.read(_controls.notifier).add(updatedControl);
  }

  void _handleSingleControl(RemoteControl update) {
    if (update.isDeletion) {
      _deleteControl(update);
    } else if (_ref.read(_controls).containsKey(update.id)) {
      _updateControl(update);
    } else {
      final toSend = _generateControl(update);
      _ref.read(_controls.notifier).add(toSend);
    }
  }

  void processControls(List<RemoteControl> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleControls(updates);
    } else {
      for (final control in updates) {
        _handleSingleControl(control);
      }
    }
  }

  Discipline _generateDiscipline(RemoteDiscipline discipline) {
    return Discipline(
        id: discipline.id,
        name: discipline.name,
        controls: discipline.controls);
  }

  void _deleteDiscipline(RemoteDiscipline toDelete) {
    // TODO this is a big fucking deal (but MeOS will send MOPComplete)
    _ref.read(_disciplines.notifier).remove(toDelete.id);
  }

  void _handleMultipleDisciplines(List<RemoteDiscipline> updates) {
    final Map<int, Discipline> toSend = {};
    for (final discipline in updates) {
      if (discipline.isDeletion) {
        _deleteDiscipline(discipline);
      } else if (_ref.read(_disciplines).containsKey(discipline.id)) {
        _updateDiscipline(discipline);
      } else {
        toSend[discipline.id] = _generateDiscipline(discipline);
      }
      _ref.read(_disciplines.notifier).batchAdd(toSend);
    }
  }

  void _updateDiscipline(RemoteDiscipline update) {
    final updatedDiscipline = _generateDiscipline(update);
    for (final runner in _ref.read(_runners).values) {
      if (runner.discipline.id == update.id) {
        _ref
            .read(_runners.notifier)
            .add(runner.copyWith(discipline: updatedDiscipline));
      }
    }
    _ref.read(_disciplines.notifier).add(updatedDiscipline);
  }

  void _handleSingleDiscipline(RemoteDiscipline update) {
    if (update.isDeletion) {
      _deleteDiscipline(update);
    } else if (_ref.read(_disciplines).containsKey(update.id)) {
      _updateDiscipline(update);
    } else {
      final toSend = _generateDiscipline(update);
      _ref.read(_disciplines.notifier).add(toSend);
    }
  }

  void processDisciplines(List<RemoteDiscipline> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleDisciplines(updates);
    } else {
      for (final discipline in updates) {
        _handleSingleDiscipline(discipline);
      }
    }
  }

  Runner _generateRunner(RemoteRunner runner) {
    final punches = {
      for (MapEntry<int, int> entry in runner.radioTimes.entries)
        entry.key: PunchStatus(
            punchedAt: _determineStartTime(runner.startTime)
                .add(_determineRunningTime(entry.value)),
            punchedAfter: (_determineRunningTime(entry.value)),
            isRead: false,
            receivedAt: DateTime.now())
    };

    final finish = FinishStatus(
        isPunched: runner.isFinished,
        punchedAt: runner.isFinished
            ? _determineStartTime(runner.startTime)
                .add(_determineRunningTime(runner.runningTime))
            : _placeHolderTime,
        punchedAfter: runner.isFinished
            ? _determineRunningTime(runner.runningTime)
            : const Duration(milliseconds: 0),
        receivedAt: DateTime.now(),
        isRead: false);

    return Runner(
        id: runner.id,
        name: runner.name,
        club: _clubForRunner(runner.clubId),
        discipline: _disciplineForRunner(runner.discId),
        country: runner.country,
        numberBib: runner.numberBib,
        status: runner.status,
        hasNoClub: runner.hasNoClub,
        radioPunches: punches,
        finishPunch: finish,
        startTime: _determineStartTime(runner.startTime),
        hasStatusUpdate: runner.status != RunnerStatus.Unknown,
        updatedAt: DateTime.now());
  }

  Club _clubForRunner(int clubId) {
    if (!_ref.read(_clubs).containsKey(clubId)) {
      final placeholder =
          Club(id: clubId, name: "PLACEHOLDER", country: Country.None);
      _ref.read(_clubs.notifier).add(placeholder);
    }
    return (_ref.read(_clubs)[clubId]!);
  }

  Discipline _disciplineForRunner(int discId) {
    if (!_ref.read(_disciplines).containsKey(discId)) {
      final placeholder =
          Discipline(id: discId, name: "PLACEHOLDER", controls: const []);
      _ref.read(_disciplines.notifier).add(placeholder);
    }
    return (_ref.read(_disciplines)[discId]!);
  }

  DateTime _determineStartTime(int milliseconds) {
    return Competition.date!.add(Duration(milliseconds: milliseconds));
  }

  Duration _determineRunningTime(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }

  void _deleteRunner(RemoteRunner toDelete) {
    // TODO maybe nothing?
    _ref.read(_runners.notifier).remove(toDelete.id);
  }

  void _handleMultipleRunners(List<RemoteRunner> updates) {
    final Map<int, Runner> toSend = {};
    for (final runner in updates) {
      if (runner.isDeletion) {
        _deleteRunner(runner);
      } else if (_ref.read(_runners).containsKey(runner.id)) {
        _updateRunner(runner);
      } else {
        toSend[runner.id] = _generateRunner(runner);
      }
    }
    _ref.read(_runners.notifier).batchAdd(toSend);
  }

  void _updateRunner(RemoteRunner update) {
    final updatedRunner = _generateRunner(update);
    _ref
        .read(_runners.notifier)
        .add(_ref.read(_runners)[update.id]!.updateFrom(updatedRunner));
  }

  void _handleSingleRunner(RemoteRunner update) {
    if (update.isDeletion) {
      _deleteRunner(update);
    } else if (_ref.read(_runners).containsKey(update.id)) {
      _updateRunner(update);
    } else {
      final newRunner = _generateRunner(update);
      _ref.read(_runners.notifier).add(newRunner);
    }
  }

  void processRunners(List<RemoteRunner> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleRunners(updates);
    } else {
      for (final runner in updates) {
        _handleSingleRunner(runner);
      }
    }
  }
}
