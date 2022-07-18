import 'package:attempt4/model/dataclasses/immutable/punch_status.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/country.dart';
import '../../enums/runner_status.dart';
import 'club.dart';
import 'discipline.dart';

@immutable
class Runner {
  const Runner(
      {required this.id,
      required this.name,
      required this.club,
      required this.discipline,
      required this.country,
      required this.numberBib,
      required this.status,
      required this.hasNoClub,
      required this.punches,
      required this.startTime,
      required this.finishedAfter,
      required this.finishedAt,
      required this.hasRunningTimeUpdate,
      required this.hasStatusUpdate,
      required this.updatedAt});

  final int id;
  final String name;
  final Club club;
  final Discipline discipline;
  final Country country;
  final String? numberBib;
  final RunnerStatus status;
  final bool hasNoClub;
  final Map<int, PunchStatus> punches;
  final DateTime startTime;
  final Duration finishedAfter;
  final DateTime finishedAt;

  final bool
      hasRunningTimeUpdate; // TODO this is determined in a bad way. we need hasFinished and it should be figured out by the reader, not the listener
  final bool hasStatusUpdate;
  final DateTime updatedAt;

  Runner copyWith({
    Club? club,
    Discipline? discipline,
  }) {
    return Runner(
        id: id,
        name: name,
        club: club ?? this.club,
        discipline: discipline ?? this.discipline,
        country: country,
        numberBib: numberBib,
        status: status,
        hasNoClub: hasNoClub,
        punches: punches,
        startTime: startTime,
        finishedAfter: finishedAfter,
        finishedAt: finishedAt,
        hasRunningTimeUpdate: hasRunningTimeUpdate,
        hasStatusUpdate: hasStatusUpdate,
        updatedAt: DateTime.now());
  }

  Map<int, PunchStatus> _determinePunchUpdates(Runner update) {
    for (final newPunch in update.punches.entries) {
      if (punches.containsKey(newPunch.key)) {
        if (!punches[newPunch.key]!.hasSameTimes(newPunch.value)) {
          punches[newPunch.key] = newPunch.value;
        }
      } else {
        punches[newPunch.key] = newPunch.value;
      }
    }

    return punches;
  }

  Runner updateFrom(Runner update) {
    return Runner(
        id: id,
        name: update.name,
        club: update.club,
        discipline: update.discipline,
        country: update.country,
        numberBib: update.numberBib,
        status: update.status,
        hasNoClub: update.hasNoClub,
        punches: _determinePunchUpdates(update),
        startTime: update.startTime,
        finishedAfter: update.finishedAfter,
        finishedAt: update.finishedAt,
        hasRunningTimeUpdate: finishedAfter != update.finishedAfter,
        hasStatusUpdate: status != update.status,
        updatedAt: DateTime.now());
  }

// TODO confusing boolean name
  Runner togglePunchUpdate(int controlId, bool markAsRead) {
    if (punches.containsKey(controlId)) {
      if (markAsRead) {
        punches[controlId] = punches[controlId]!.copyWith(isRead: true);
      } else {
        // toggle
        punches[controlId] =
            punches[controlId]!.copyWith(isRead: !punches[controlId]!.isRead);
      }
    }

    return Runner(
        id: id,
        name: name,
        club: club,
        discipline: discipline,
        country: country,
        numberBib: numberBib,
        status: status,
        hasNoClub: hasNoClub,
        punches: punches,
        startTime: startTime,
        finishedAfter: finishedAfter,
        finishedAt: finishedAt,
        hasRunningTimeUpdate: hasRunningTimeUpdate,
        hasStatusUpdate: hasStatusUpdate,
        updatedAt: DateTime.now());
  }

  Runner toggleFinishUpdate(bool markAsRead) {
    return Runner(
        id: id,
        name: name,
        club: club,
        discipline: discipline,
        country: country,
        numberBib: numberBib,
        status: status,
        hasNoClub: hasNoClub,
        punches: punches,
        startTime: startTime,
        finishedAfter: finishedAfter,
        finishedAt: finishedAt,
        hasRunningTimeUpdate: markAsRead ? false : !hasRunningTimeUpdate,
        hasStatusUpdate: hasStatusUpdate,
        updatedAt: DateTime.now());
  }
}

class RunnerMap extends StateNotifier<Map<int, Runner>> {
  RunnerMap([Map<int, Runner>? initialControls]) : super(initialControls ?? {});

  void add(Runner runner) {
    state = {...state, runner.id: runner};
  }

  void batchAdd(Map<int, Runner> runners) {
    state = {...state, ...runners};
  }

  void clear() {
    state = {};
  }

  void toggleControlUpdateSingle(int runnerId, int controlId) {
    if (state.containsKey(runnerId)) {
      final update = {
        runnerId: state[runnerId]!.togglePunchUpdate(controlId, false)
      };
      state = {...state, ...update};
    }
  }

  void toggleFinishUpdateSingle(int runnerId) {
    if (state.containsKey(runnerId)) {
      final update = {runnerId: state[runnerId]!.toggleFinishUpdate(false)};
      state = {...state, ...update};
    }
  }

  void togglePunchUpdateDiscipline(int discId, int controlId) {
    final Map<int, Runner> update = {};
    for (Runner runner in state.values) {
      if (runner.discipline.id == discId &&
          runner.punches.containsKey(controlId)) {
        update[runner.id] = runner.togglePunchUpdate(controlId, true);
      }
    }
    if (update.isNotEmpty) {
      state = {...state, ...update};
    }
  }

  void toggleFinishUpdateDiscipline(int discId) {
    final Map<int, Runner> update = {};
    for (Runner runner in state.values) {
      if (runner.discipline.id == discId && runner.hasRunningTimeUpdate) {
        update[runner.id] = runner.toggleFinishUpdate(true);
      }
    }
    if (update.isNotEmpty) {
      state = {...state, ...update};
    }
  }

  void edit(Runner runner) {
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


// import 'package:flutter/foundation.dart' show immutable;
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../enums/country.dart';
// import '../../enums/runner_status.dart';
// import 'club.dart';
// import 'discipline.dart';

// @immutable
// class Runner {
//   const Runner(
//       {required this.id,
//       required this.name,
//       required this.club,
//       required this.discipline,
//       required this.country,
//       required this.numberBib,
//       required this.status,
//       required this.hasNoClub,
//       required this.radioTimes,
//       required this.startTime,
//       required this.runningTime,
//       required this.radioUpdates,
//       required this.hasRunningTimeUpdate,
//       required this.hasStatusUpdate,
//       required this.updatedAt});

//   final int id;
//   final String name;
//   final Club club;
//   final Discipline discipline;
//   final Country country;
//   final String? numberBib;
//   final RunnerStatus status;
//   final bool hasNoClub;
//   final Map<int, Duration> radioTimes;
//   final DateTime startTime;
//   final Duration runningTime;

//   final Set<int> radioUpdates;
//   final bool hasRunningTimeUpdate;
//   final bool hasStatusUpdate;
//   final DateTime updatedAt;

//   Runner copyWith({
//     Club? club,
//     Discipline? discipline,
//   }) {
//     return Runner(
//         id: id,
//         name: name,
//         club: club ?? this.club,
//         discipline: discipline ?? this.discipline,
//         country: country,
//         numberBib: numberBib,
//         status: status,
//         hasNoClub: hasNoClub,
//         radioTimes: radioTimes,
//         startTime: startTime,
//         runningTime: runningTime,
//         radioUpdates: radioUpdates,
//         hasRunningTimeUpdate: hasRunningTimeUpdate,
//         hasStatusUpdate: hasStatusUpdate,
//         updatedAt: DateTime.now());
//   }

//   Set<int> _determineRadioUpdates(Runner update) {
//     final updateSet = Set<int>.from(radioUpdates);

//     // we only care about punches at controls relevant to the discipline
//     // there may be mispunches in here
//     // we keep them though - may be administrative error
//     Map<int, Duration> curatedCurrent = {};
//     for (final currentTime in radioTimes.entries) {
//       if (discipline.controls.contains(currentTime.key)) {
//         curatedCurrent[currentTime.key] = currentTime.value;
//       }
//     }

//     // ditto
//     Map<int, Duration> curatedUpdated = {};
//     for (final currentTime in update.radioTimes.entries) {
//       if (discipline.controls.contains(currentTime.key)) {
//         curatedUpdated[currentTime.key] = currentTime.value;
//       }
//     }

//     // check for brand new times or changes to existing ones
//     for (final currentTime in curatedUpdated.entries) {
//       if (!curatedCurrent.containsKey(currentTime.key)) {
//         updateSet.add(currentTime.key); // new time
//       } else if (currentTime.value != curatedCurrent[currentTime.key]) {
//         updateSet.add(
//             currentTime.key); // update to existing time (extremely unusual)
//       }
//     }

//     return updateSet;
//   }

//   void recalculatePunchTimes() {
//     // TODO: this is used when startTime is changed
//   }

//   Runner updateFrom(Runner update) {
//     return Runner(
//         id: id,
//         name: update.name,
//         club: update.club,
//         discipline: update.discipline,
//         country: update.country,
//         numberBib: update.numberBib,
//         status: update.status,
//         hasNoClub: update.hasNoClub,
//         radioTimes: update.radioTimes,
//         startTime: update.startTime,
//         runningTime: update.runningTime,
//         radioUpdates: _determineRadioUpdates(update),
//         hasRunningTimeUpdate: runningTime != update.runningTime,
//         hasStatusUpdate: status != update.status,
//         updatedAt: DateTime.now());
//   }

//   Runner toggleControlUpdate(int controlId, bool markAsRead) {
//     final updateSet = Set<int>.from(radioUpdates);

//     if (markAsRead) {
//       updateSet.remove(controlId);
//     } else {
//       // toggle
//       if (updateSet.contains(controlId)) {
//         updateSet.remove(controlId);
//       } else {
//         updateSet.add(controlId);
//       }
//     }

//     return Runner(
//         id: id,
//         name: name,
//         club: club,
//         discipline: discipline,
//         country: country,
//         numberBib: numberBib,
//         status: status,
//         hasNoClub: hasNoClub,
//         radioTimes: radioTimes,
//         startTime: startTime,
//         runningTime: runningTime,
//         radioUpdates: updateSet,
//         hasRunningTimeUpdate: hasRunningTimeUpdate,
//         hasStatusUpdate: hasStatusUpdate,
//         updatedAt: DateTime.now());
//   }

//   Runner toggleFinishUpdate(bool markAsRead) {
//     return Runner(
//         id: id,
//         name: name,
//         club: club,
//         discipline: discipline,
//         country: country,
//         numberBib: numberBib,
//         status: status,
//         hasNoClub: hasNoClub,
//         radioTimes: radioTimes,
//         startTime: startTime,
//         runningTime: runningTime,
//         radioUpdates: radioUpdates,
//         hasRunningTimeUpdate: markAsRead ? false : !hasRunningTimeUpdate,
//         hasStatusUpdate: hasStatusUpdate,
//         updatedAt: DateTime.now());
//   }
// }

// class RunnerMap extends StateNotifier<Map<int, Runner>> {
//   RunnerMap([Map<int, Runner>? initialControls]) : super(initialControls ?? {});

//   void add(Runner runner) {
//     state = {...state, runner.id: runner};
//   }

//   void batchAdd(Map<int, Runner> runners) {
//     state = {...state, ...runners};
//   }

//   void clear() {
//     state = {};
//   }

//   void toggleControlUpdateSingle(int runnerId, int controlId) {
//     if (state.containsKey(runnerId)) {
//       final update = {
//         runnerId: state[runnerId]!.toggleControlUpdate(controlId, false)
//       };
//       state = {...state, ...update};
//     }
//   }

//   void toggleFinishUpdateSingle(int runnerId) {
//     if (state.containsKey(runnerId)) {
//       final update = {runnerId: state[runnerId]!.toggleFinishUpdate(false)};
//       state = {...state, ...update};
//     }
//   }

//   void toggleControlUpdateDiscipline(int discId, int controlId) {
//     final Map<int, Runner> update = {};
//     for (Runner runner in state.values) {
//       if (runner.discipline.id == discId &&
//           runner.radioUpdates.contains(controlId)) {
//         update[runner.id] = runner.toggleControlUpdate(controlId, true);
//       }
//     }
//     if (update.isNotEmpty) {
//       state = {...state, ...update};
//     }
//   }

//   void toggleFinishUpdateDiscipline(int discId) {
//     final Map<int, Runner> update = {};
//     for (Runner runner in state.values) {
//       if (runner.discipline.id == discId && runner.hasRunningTimeUpdate) {
//         update[runner.id] = runner.toggleFinishUpdate(true);
//       }
//     }
//     if (update.isNotEmpty) {
//       state = {...state, ...update};
//     }
//   }

//   void edit(Runner runner) {
//     print("NYI LOL");
//   }

//   void remove(int id) {
//     state = {
//       for (final e in state.entries)
//         if (e.key != id) e.key: e.value,
//     };
//     // state = Map.fromEntries(state.entries.where((entry) => entry.key != id));
//   }
// }
