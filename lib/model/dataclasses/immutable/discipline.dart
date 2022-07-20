import 'package:attempt4/model/dataclasses/immutable/control_settings.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Discipline {
  const Discipline(
      {required this.id, required this.name, required this.controls});

  final int id;
  final String name;
  final Map<int, ControlSettings> controls;

  Discipline copyWith({required Map<int, ControlSettings> controls}) {
    return Discipline(id: id, name: name, controls: controls);
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

  void toggleSorting(int discId, int controlId) {
    if (state.containsKey(discId) &&
        state[discId]!.controls.containsKey(controlId)) {
      final controls = state[discId]!.controls;
      controls[controlId] = controls[controlId]!.toggleSorting();
      final changedDisc = state[discId]!.copyWith(controls: controls);
      state = {...state, changedDisc.id: changedDisc};
      // TODO WE UPDATE THE WHOLE DISCIPLINE STATE BECAUSE WE CHANGE SORTING FOR ONE CONTROL FOR ONE CLASS LOL
    }
  }

  void remove(int id) {
    state = {
      for (final e in state.entries)
        if (e.key != id) e.key: e.value,
    };
  }
}
