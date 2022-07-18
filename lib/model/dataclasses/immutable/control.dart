import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Control {
  const Control({required this.id, required this.name});

  final int id;
  final String name;
}

class ControlMap extends StateNotifier<Map<int, Control>> {
  ControlMap([Map<int, Control>? initialControls])
      : super(initialControls ?? {});

  void add(Control control) {
    state = {...state, control.id: control};
  }

  void batchAdd(Map<int, Control> controls) {
    state = {...state, ...controls};
  }

  void clear() {
    state = {};
  }

  void edit(Control control) {
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
