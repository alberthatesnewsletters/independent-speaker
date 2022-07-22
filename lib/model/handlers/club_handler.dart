import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dataclasses/immutable/club.dart';
import '../dataclasses/immutable/runner.dart';
import '../dataclasses/remote/club.dart';

class ClubHandler {
  ClubHandler(this._ref, this._clubs, this._runners);

  final StateNotifierProvider<ClubMap, Map<int, Club>> _clubs;
  final StateNotifierProvider<RunnerMap, Map<int, Runner>> _runners;
  final WidgetRef _ref;
  final int _batchUpdateThreshold = 3; // number pulled out of my ass

  Club _generateClub(RemoteClub club) {
    return Club(id: club.id, name: club.name, country: club.country);
  }

  void _deleteClub(RemoteClub toDelete) {
    // TODO find relevant runners, give them no club
    _ref.read(_clubs.notifier).remove(toDelete.id);
  }

  void _handleMultipleClubs(List<RemoteClub> updates) {
    final Map<int, Club> toSend = {};
    for (final club in updates) {
      if (club.isDeletion) {
        _deleteClub(club);
      } else if (_ref.read(_clubs).containsKey(club.id)) {
        _updateClub(club);
      } else {
        toSend[club.id] = _generateClub(club);
      }
    }
    _ref.read(_clubs.notifier).batchAdd(toSend);
  }

  void _updateClub(RemoteClub update) {
    final updatedClub = _generateClub(update);
    for (final runner in _ref.read(_runners).values) {
      if (runner.club.id == update.id) {
        _ref.read(_runners.notifier).add(runner.copyWith(club: updatedClub));
      }
    }
    _ref.read(_clubs.notifier).add(updatedClub);
  }

  void _handleSingleClub(RemoteClub update) {
    if (update.isDeletion) {
      _deleteClub(update);
    } else if ((_ref.read(_clubs).containsKey(update.id))) {
      _updateClub(update);
    } else {
      final toSend = _generateClub(update);
      _ref.read(_clubs.notifier).add(toSend);
    }
  }

  void processClubs(List<RemoteClub> updates) {
    if (updates.length >= _batchUpdateThreshold) {
      _handleMultipleClubs(updates);
    } else {
      for (final club in updates) {
        _handleSingleClub(club);
      }
    }
  }
}
