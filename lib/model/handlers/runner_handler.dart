import '../../main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  RunnerHandler(this._clubs, this._disciplines, this._runners, this._ref);

  final StateNotifierProvider<ClubMap, Map<int, Club>> _clubs;
  final StateNotifierProvider<DisciplineMap, Map<int, Discipline>> _disciplines;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
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
            placement: null, // TODO
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
        placement: null, // TODO
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

  // TODO these all need to be recalculated if competition date changes
  DateTime _determineStartTime(int milliseconds) {
    return _ref
        .read(competitionInfoProvider)
        .date
        .add(Duration(milliseconds: milliseconds));
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
    final Map<int, Set<int>> discRadioChecks = {};
    final Map<int, bool> discFinishChecks = {};
    for (final runner in updates) {
      if (runner.isDeletion) {
        _deleteRunner(runner);
      } else if (_ref.read(_runners).containsKey(runner.id)) {
        _updateRunner(runner);
      } else {
        final newRunner = _generateRunner(runner);
        toSend[runner.id] = newRunner;

        if (discRadioChecks.containsKey(newRunner.discipline.id)) {
          discRadioChecks[newRunner.discipline.id]!
              .addAll(newRunner.radioPunches.keys.toSet());
        } else {
          discRadioChecks[newRunner.discipline.id] =
              newRunner.radioPunches.keys.toSet();
        }

        if (discFinishChecks.containsKey(newRunner.discipline.id)) {
          if (discFinishChecks[newRunner.discipline.id] == false) {
            discFinishChecks[newRunner.discipline.id] =
                newRunner.finishPunch.isPunched;
          }
        } else {
          discFinishChecks[newRunner.discipline.id] =
              newRunner.finishPunch.isPunched;
        }
      }
    }
    _ref.read(_runners.notifier).batchAdd(toSend);

    for (final toCalculate in discRadioChecks.entries) {
      _determinePlacements(toCalculate.key, toCalculate.value,
          discFinishChecks[toCalculate.key]!);
    }
  }

  void _determinePlacements(
      int discId, Set<int> radiosToCalculate, bool calculateFinish) {
    for (final radioPunch in radiosToCalculate) {
      final currentStandings = _ref
          .read(_runners)
          .values
          .where((element) =>
              element.discipline.id == discId &&
              element.radioPunches.containsKey(radioPunch))
          .toList();

      currentStandings.sort((a, b) => a.radioPunches[radioPunch]!.punchedAfter
          .compareTo(b.radioPunches[radioPunch]!.punchedAfter));

      Map<int, Runner> updatedRunners = {};
      for (int i = 0; i < currentStandings.length; i++) {
        final updatedRunner =
            currentStandings[i].newRadioPlacement(radioPunch, i + 1);
        if (updatedRunner != null) {
          updatedRunners[updatedRunner.id] = updatedRunner;
        }
      }
      _ref.read(_runners.notifier).batchAdd(updatedRunners);
    }

    if (calculateFinish) {
      final currentStandings = _ref
          .read(_runners)
          .values
          .where((element) =>
              element.discipline.id == discId && element.finishPunch.isPunched)
          .toList();

      currentStandings.sort((a, b) =>
          a.finishPunch.punchedAfter.compareTo(b.finishPunch.punchedAfter));

      Map<int, Runner> updatedRunners = {};
      for (int i = 0; i < currentStandings.length; i++) {
        final updatedRunner = currentStandings[i].newFinishPlacement(i + 1);
        if (updatedRunner != null) {
          updatedRunners[updatedRunner.id] = updatedRunner;
        }
      }
      _ref.read(_runners.notifier).batchAdd(updatedRunners);
    }
  }

  void _updateRunner(RemoteRunner update) {
    final updatedRunner = _generateRunner(update);
    final currentRunner = _ref.read(_runners)[update.id]!;
    Set<int> radiosToCheck = {};
    bool checkFinish = false;

    for (final radioPunch in updatedRunner.radioPunches.entries) {
      if (currentRunner.radioPunches.containsKey(radioPunch.key)) {
        if (currentRunner.radioPunches[radioPunch.key]!
            .hasSameTimes(radioPunch.value)) {
          radiosToCheck.add(radioPunch.key);
        }
      } else {
        radiosToCheck.add(radioPunch.key);
      }
    }

    if (updatedRunner.finishPunch.isPunched &&
        !updatedRunner.finishPunch.hasSameTimes(currentRunner.finishPunch)) {
      checkFinish = true;
    }

    _ref
        .read(_runners.notifier)
        .add(_ref.read(_runners)[update.id]!.updateFrom(updatedRunner));

    _determinePlacements(update.discId, radiosToCheck, checkFinish);
  }

  void _handleSingleRunner(RemoteRunner update) {
    if (update.isDeletion) {
      _deleteRunner(update);
    } else if (_ref.read(_runners).containsKey(update.id)) {
      _updateRunner(update);
    } else {
      final newRunner = _generateRunner(update);
      final radiosToCheck = update.radioTimes.keys.toSet();
      final checkFinish = update.isFinished;

      _ref.read(_runners.notifier).add(newRunner);

      _determinePlacements(update.discId, radiosToCheck, checkFinish);
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
