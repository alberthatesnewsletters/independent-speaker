import 'package:attempt4/model/enums/sorting.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class ControlSettings {
  const ControlSettings(
      {required this.id, required this.name, required this.sorting});

  final int id;
  final String name;
  final Sorting sorting;

  ControlSettings toggleSorting() {
    return ControlSettings(
        id: id,
        name: name,
        sorting: sorting == Sorting.NewestFirst
            ? Sorting.FastestFirst
            : Sorting.NewestFirst);
  }

  // TODO Map<int, Map<int, Sorting>> instead of having this in a discipline

  ControlSettings newName(String newName) {
    return ControlSettings(id: id, name: newName, sorting: sorting);
  }
}
