import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AllDisciplinesTab {
  const AllDisciplinesTab({required this.current, required this.trackAll});

  final int? current;
  final bool trackAll;
}

class AllDisciplinesTabSettings extends StateNotifier<AllDisciplinesTab> {
  AllDisciplinesTabSettings([AllDisciplinesTab? allDisciplines])
      : super(allDisciplines ??
            const AllDisciplinesTab(current: null, trackAll: true));

  void trackAll() {
    state = AllDisciplinesTab(current: state.current, trackAll: true);
  }

  void stopTrackAll() {
    state = AllDisciplinesTab(current: state.current, trackAll: false);
  }

// TODO maybe not the smartest way
  void toggleTrackAll() {
    state =
        AllDisciplinesTab(current: state.current, trackAll: !state.trackAll);
  }

  void setTrackAll(bool setting) {
    state = AllDisciplinesTab(current: state.current, trackAll: setting);
  }

  void viewDiscipline(int? id) {
    state = AllDisciplinesTab(current: id, trackAll: state.trackAll);
  }
}
