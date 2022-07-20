import 'package:attempt4/model/dataclasses/immutable/control_settings.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/sorting.dart';

@immutable
class Discipline {
  const Discipline(
      {required this.id,
      required this.name,
      required this.controls,
      required this.finishSorting});

  final int id;
  final String name;
  final Map<int, ControlSettings> controls;
  final Sorting finishSorting;

  Discipline copyWith({required Map<int, ControlSettings> controls}) {
    return Discipline(
        id: id, name: name, controls: controls, finishSorting: finishSorting);
  }

  Discipline? toggleControlSorting(int controlId) {
    if (controls.containsKey(controlId)) {
      controls[controlId] = controls[controlId]!.toggleSorting();
      return Discipline(
          id: id, name: name, controls: controls, finishSorting: finishSorting);
    } else {
      return null;
    }
  }

  Discipline toggleFinishSorting() {
    return Discipline(
        id: id,
        name: name,
        controls: controls,
        finishSorting: finishSorting == Sorting.NewestFirst
            ? Sorting.FastestFirst
            : Sorting.NewestFirst);
  }
}

class DisciplineMap extends StateNotifier<Map<int, Discipline>> {
  DisciplineMap([Map<int, Discipline>? initialDisciplines])
      : super(initialDisciplines ?? {});

  void add(Discipline discipline) {
    state = {...state, discipline.id: discipline};
  }

  void batchAdd(Map<int, Discipline> disciplines) {
    state = {...state, ...disciplines};
  }

  void clear() {
    state = {};
  }

  void toggleControlSorting(int discId, int controlId) {
    if (state.containsKey(discId)) {
      final changedDisc = state[discId]!.toggleControlSorting(controlId);
      if (changedDisc != null) {
        state = {...state, changedDisc.id: changedDisc};
        // TODO WE UPDATE THE WHOLE DISCIPLINE STATE BECAUSE WE CHANGE SORTING FOR ONE CONTROL FOR ONE CLASS LOL
      }
    }
  }

  void toggleFinishSorting(int discId) {
    if (state.containsKey(discId)) {
      final changedDisc = state[discId]!.toggleFinishSorting();
      state = {...state, changedDisc.id: changedDisc};
    }
  }

  void remove(int id) {
    state = {
      for (final e in state.entries)
        if (e.key != id) e.key: e.value,
    };
  }
}
