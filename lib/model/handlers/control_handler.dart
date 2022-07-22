import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dataclasses/immutable/control.dart';
import '../dataclasses/immutable/control_settings.dart';
import '../dataclasses/immutable/discipline.dart';
import '../dataclasses/remote/control.dart';

class ControlHandler {
  ControlHandler(this._controls, this._disciplines, this._ref);

  final StateNotifierProvider<ControlMap, Map<int, Control>> _controls;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final WidgetRef _ref;
  final int _batchUpdateThreshold = 3; // number pulled out of my ass

  Control _generateControl(RemoteControl control) {
    return Control(id: control.id, name: control.name);
  }

  void _deleteControl(RemoteControl toDelete) {
    for (final discipline in _ref.read(_disciplines).values) {
      if (discipline.controls.containsKey(toDelete.id)) {
        final newControls = Map<int, ControlSettings>.from(discipline.controls);
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
    for (Discipline discipline in _ref.read(_disciplines).values) {
      if (discipline.controls.containsKey(update.id)) {
        final controls = discipline.controls;
        controls[update.id] = controls[update.id]!.newName(update.name);
        _ref
            .read(_disciplines.notifier)
            .add(discipline.copyWith(controls: controls));
      }
    }
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
}
