import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dataclasses/immutable/control.dart';
import '../dataclasses/immutable/control_settings.dart';
import '../dataclasses/immutable/discipline.dart';
import '../dataclasses/immutable/runner.dart';
import '../dataclasses/remote/discipline.dart';
import '../enums/sorting.dart';

class DisciplineHandler {
  DisciplineHandler(
      this._controls, this._disciplines, this._runners, this._ref);

  final StateNotifierProvider<ControlMap, Map<int, Control>> _controls;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
  final WidgetRef _ref;
  final int _batchUpdateThreshold = 3; // number pulled out of my ass

  Discipline _generateDiscipline(RemoteDiscipline discipline) {
    final controls = {
      for (var e in discipline.controls)
        e: ControlSettings(
            id: e,
            name: _ref.read(_controls).containsKey(e)
                ? _ref.read(_controls)[e]!.name
                : "PLACEHOLDER",
            sorting: Sorting.NewestFirst)
    };
    return Discipline(
        id: discipline.id,
        name: discipline.name,
        isFollowed: false,
        controls: controls,
        finishSorting: Sorting.NewestFirst);
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
}
