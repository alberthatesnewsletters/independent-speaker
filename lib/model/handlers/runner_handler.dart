import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dataclasses/immutable/competition.dart';
import '../dataclasses/immutable/club.dart';
import '../dataclasses/immutable/discipline.dart';
import '../dataclasses/immutable/finish_status.dart';
import '../dataclasses/immutable/punch_status.dart';
import '../dataclasses/immutable/runner.dart';
import '../dataclasses/remote/runner.dart';
import '../enums/country.dart';
import '../enums/runner_status.dart';
import '../enums/sorting.dart';

class RunnerHandler {
  RunnerHandler(this._clubs, this._disciplines, this._runners,
      this._competition, this._ref);

  final StateNotifierProvider<ClubMap, Map<int, Club>> _clubs;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
  final Competition _competition;
  final WidgetRef _ref;
  final int _batchUpdateThreshold = 3; // number pulled out of my ass
  final DateTime _placeHolderTime = DateTime(2000);

  Runner _generateRunner(RemoteRunner runner) {
    final punches = {
      for (MapEntry<int, int> entry in runner.radioTimes.entries)
        entry.key: PunchStatus(
            punchedAt: _determineStartTime(runner.startTime)
                .add(_determineRunningTime(entry.value)),
            punchedAfter: (_determineRunningTime(entry.value)),
            isRead: false,
            receivedAt: DateTime.now())
    };

    final finish = FinishStatus(
        isPunched: runner.isFinished,
        punchedAt: runner.isFinished
            ? _determineStartTime(runner.startTime)
                .add(_determineRunningTime(runner.runningTime))
            : _placeHolderTime,
        punchedAfter: runner.isFinished
            ? _determineRunningTime(runner.runningTime)
            : const Duration(milliseconds: 0),
        receivedAt: DateTime.now(),
        isRead: false);

    return Runner(
        id: runner.id,
        name: runner.name,
        club: _clubForRunner(runner.clubId),
        discipline: _disciplineForRunner(runner.discId),
        country: runner.country,
        numberBib: runner.numberBib,
        status: runner.status,
        hasNoClub: runner.hasNoClub,
        radioPunches: punches,
        finishPunch: finish,
        startTime: _determineStartTime(runner.startTime),
        hasStatusUpdate: runner.status != RunnerStatus.Unknown,
        updatedAt: DateTime.now());
  }

  Club _clubForRunner(int clubId) {
    if (!_ref.read(_clubs).containsKey(clubId)) {
      final placeholder =
          Club(id: clubId, name: "PLACEHOLDER", country: Country.None);
      _ref.read(_clubs.notifier).add(placeholder);
    }
    return (_ref.read(_clubs)[clubId]!);
  }

  Discipline _disciplineForRunner(int discId) {
    if (!_ref.read(_disciplines).containsKey(discId)) {
      final placeholder = Discipline(
          id: discId,
          name: "PLACEHOLDER",
          isFollowed: false,
          controls: const {},
          finishSorting: Sorting.NewestFirst);
      _ref.read(_disciplines.notifier).add(placeholder);
    }
    return (_ref.read(_disciplines)[discId]!);
  }

  DateTime _determineStartTime(int milliseconds) {
    return _competition.date.add(Duration(milliseconds: milliseconds));
  }

  Duration _determineRunningTime(int milliseconds) {
    return Duration(milliseconds: milliseconds);
  }

  void _deleteRunner(RemoteRunner toDelete) {
    // TODO maybe nothing?
    _ref.read(_runners.notifier).remove(toDelete.id);
  }

  void _handleMultipleRunners(List<RemoteRunner> updates) {
    final Map<int, Runner> toSend = {};
    for (final runner in updates) {
      if (runner.isDeletion) {
        _deleteRunner(runner);
      } else if (_ref.read(_runners).containsKey(runner.id)) {
        _updateRunner(runner);
      } else {
        toSend[runner.id] = _generateRunner(runner);
      }
    }
    _ref.read(_runners.notifier).batchAdd(toSend);
  }

  void _updateRunner(RemoteRunner update) {
    final updatedRunner = _generateRunner(update);
    _ref
        .read(_runners.notifier)
        .add(_ref.read(_runners)[update.id]!.updateFrom(updatedRunner));
  }

  void _handleSingleRunner(RemoteRunner update) {
    if (update.isDeletion) {
      _deleteRunner(update);
    } else if (_ref.read(_runners).containsKey(update.id)) {
      _updateRunner(update);
    } else {
      final newRunner = _generateRunner(update);
      _ref.read(_runners.notifier).add(newRunner);
    }
  }

  void processRunners(List<RemoteRunner> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleRunners(updates);
    } else {
      for (final runner in updates) {
        _handleSingleRunner(runner);
      }
    }
  }
}
