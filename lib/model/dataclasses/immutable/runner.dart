import 'package:attempt4/model/dataclasses/immutable/punch_status.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/country.dart';
import '../../enums/runner_status.dart';
import 'club.dart';
import 'discipline.dart';
import 'finish_status.dart';

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
      required this.radioPunches,
      required this.finishPunch,
      required this.startTime,
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
  final Map<int, PunchStatus> radioPunches;
  final FinishStatus finishPunch;
  final DateTime startTime;
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
        radioPunches: radioPunches,
        finishPunch: finishPunch,
        startTime: startTime,
        hasStatusUpdate: hasStatusUpdate,
        updatedAt: DateTime.now());
  }

  Map<int, PunchStatus> _determinePunchUpdates(Runner update) {
    for (final newPunch in update.radioPunches.entries) {
      if (radioPunches.containsKey(newPunch.key)) {
        if (!radioPunches[newPunch.key]!.hasSameTimes(newPunch.value)) {
          radioPunches[newPunch.key] = newPunch.value;
        }
      } else {
        radioPunches[newPunch.key] = newPunch.value;
      }
    }

    return radioPunches;
  }

  FinishStatus _determineFinishUpdates(Runner update) {
    return (finishPunch.hasSameTimes(update.finishPunch)
        ? finishPunch
        : finishPunch.copyWith(
            punchedAt: update.finishPunch.punchedAt,
            punchedAfter: update.finishPunch.punchedAfter));
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
        radioPunches: _determinePunchUpdates(update),
        finishPunch: _determineFinishUpdates(update),
        startTime: update.startTime,
        hasStatusUpdate: status != update.status,
        updatedAt: DateTime.now());
  }

  Runner? newRadioPlacement(int radio, int placement) {
    if (radioPunches[radio]!.placement != placement) {
      radioPunches[radio] = radioPunches[radio]!.copyWith(placement: placement);
      return Runner(
          id: id,
          name: name,
          club: club,
          discipline: discipline,
          country: country,
          numberBib: numberBib,
          status: status,
          hasNoClub: hasNoClub,
          radioPunches: radioPunches,
          finishPunch: finishPunch,
          startTime: startTime,
          hasStatusUpdate: hasStatusUpdate,
          updatedAt: updatedAt);
    } else {
      return null;
    }
  }

  Runner? newFinishPlacement(int placement) {
    if (finishPunch.placement != placement) {
      return Runner(
          id: id,
          name: name,
          club: club,
          discipline: discipline,
          country: country,
          numberBib: numberBib,
          status: status,
          hasNoClub: hasNoClub,
          radioPunches: radioPunches,
          finishPunch: finishPunch.copyWith(placement: placement),
          startTime: startTime,
          hasStatusUpdate: hasStatusUpdate,
          updatedAt: updatedAt);
    } else {
      return null;
    }
  }

// TODO confusing boolean name
  Runner togglePunchUpdate(int controlId, bool markAsRead) {
    if (radioPunches.containsKey(controlId)) {
      if (markAsRead) {
        radioPunches[controlId] =
            radioPunches[controlId]!.copyWith(isRead: true);
      } else {
        // toggle
        radioPunches[controlId] = radioPunches[controlId]!
            .copyWith(isRead: !radioPunches[controlId]!.isRead);
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
        radioPunches: radioPunches,
        finishPunch: finishPunch,
        startTime: startTime,
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
        radioPunches: radioPunches,
        startTime: startTime,
        finishPunch: markAsRead
            ? finishPunch.copyWith(isRead: true)
            : finishPunch.copyWith(isRead: !finishPunch.isRead),
        hasStatusUpdate: hasStatusUpdate,
        updatedAt: DateTime.now());
  }
}

class RunnerMap extends StateNotifier<Map<int, Runner>> {
  RunnerMap([Map<int, Runner>? initialControls]) : super(initialControls ?? {});

  // mass mark as read will not work on updates fresher than this
  final _reactionBuffer = const Duration(seconds: 1);

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

  void markReadPunchUpdateDiscipline(int discId, int controlId) {
    final Map<int, Runner> update = {};
    for (Runner runner in state.values) {
      if (runner.discipline.id == discId &&
          runner.radioPunches.containsKey(controlId) &&
          !runner.radioPunches[controlId]!.isRead &&
          DateTime.now()
                  .difference(runner.radioPunches[controlId]!.receivedAt) >
              _reactionBuffer) {
        update[runner.id] = runner.togglePunchUpdate(controlId, true);
      }
    }
    if (update.isNotEmpty) {
      state = {...state, ...update};
    }
  }

  // TODO above and below
  // no mark-as-read on too-fresh updates
  // done above, untested below

  void markReadFinishUpdateDiscipline(int discId) {
    final Map<int, Runner> update = {};
    for (Runner runner in state.values) {
      if (runner.discipline.id == discId &&
          runner.finishPunch.isPunched &&
          !runner.finishPunch.isRead &&
          DateTime.now().difference(runner.finishPunch.receivedAt) >
              _reactionBuffer) {
        update[runner.id] = runner.toggleFinishUpdate(true);
      }
    }
    if (update.isNotEmpty) {
      state = {...state, ...update};
    }
  }

  void markFinishReadAll() {
    final Map<int, Runner> update = {};
    for (Runner runner in state.values) {
      if (runner.finishPunch.isPunched &&
          !runner.finishPunch.isRead &&
          DateTime.now().difference(runner.finishPunch.receivedAt) >
              _reactionBuffer) {
        update[runner.id] = runner.toggleFinishUpdate(true);
      }
      if (update.isNotEmpty) {
        state = {...state, ...update};
      }
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
