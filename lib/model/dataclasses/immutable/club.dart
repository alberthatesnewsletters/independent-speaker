import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/country.dart';

@immutable
class Club {
  const Club({required this.id, required this.name, required this.country});

  final int id;
  final String name;
  final Country country;

  // Club copyWith()
}

class ClubMap extends StateNotifier<Map<int, Club>> {
  ClubMap([Map<int, Club>? initialClubs]) : super(initialClubs ?? {});

  void add(Club club) {
    state = {...state, club.id: club};
    // if (state.containsKey(club.id)) {
    //   edit(club);
    // } else {
    //   state = {...state, club.id: club};
    // }
  }

  void batchAdd(Map<int, Club> clubs) {
    state = {...state, ...clubs};
  }

  void clear() {
    state = {};
  }

  void edit(Club club) {
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
