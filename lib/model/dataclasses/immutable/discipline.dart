import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Discipline {
  const Discipline(
      {required this.id, required this.name, required this.controls});

  final int id;
  final String name;
  final List<int> controls;

  Discipline copyWith({required List<int> controls}) {
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

  void edit(Discipline discipline) {
    print("NYI LOL");
  }

  void remove(int id) {
    state = {
      for (final e in state.entries)
        if (e.key != id) e.key: e.value,
    };
    // state = Map.fromEntries(state.entries.where((entry) => entry.key != id));
  }
}
