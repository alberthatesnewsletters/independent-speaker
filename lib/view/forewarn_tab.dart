import 'package:attempt4/model/enums/runner_status.dart';

import 'forewarn.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';
import '../model/enums/sorting.dart';

class ForewarnTab extends HookConsumerWidget {
  const ForewarnTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFinish = ref.watch(currentForewarnIsFinish);
    final discId = ref.watch(currentDisciplineId);
    final disc = ref.watch(disciplineMapProvider)[discId]!;
    if (isFinish) {
      if (disc.controls.keys.isNotEmpty) {
        // finish, with a radio before
        final controlId = disc.controls.keys.last;
        final runners = ref.watch(runnerMapProvider).values.where((element) =>
            element.discipline.id == discId &&
            element.radioPunches.containsKey(controlId) &&
            element.status == RunnerStatus.Unknown);
        return ListView(
          controller: ScrollController(),
          children: [
            for (Runner runner in runners)
              ProviderScope(
                  overrides: [currentRunner.overrideWithValue(runner)],
                  child: const Forewarn())
          ],
        );
      } else {
        // finish, with no radio before
        final runners = ref.watch(runnerMapProvider).values.where((element) =>
            element.discipline.id == discId &&
            !element.finishPunch.isPunched &&
            element.status == RunnerStatus.Unknown);
        return ListView(
          controller: ScrollController(),
          children: [
            for (Runner runner in runners)
              ProviderScope(
                  overrides: [currentRunner.overrideWithValue(runner)],
                  child: const Forewarn())
          ],
        );
      }
    } else {
      final currentControl = ref.watch(currentControlId);
      final currentControlIndex =
          disc.controls.keys.toList().indexOf(currentControl);

      if (currentControlIndex != 0) {
        // not the first radio, not the finish
        final controlId = disc.controls.keys
            .toList()[disc.controls.keys.toList().indexOf(currentControl) - 1];
        final runners = ref.watch(runnerMapProvider).values.where((element) =>
            element.discipline.id == discId &&
            element.radioPunches.containsKey(controlId) &&
            !element.radioPunches.containsKey(currentControl) &&
            element.status == RunnerStatus.Unknown);
        return ListView(
          controller: ScrollController(),
          children: [
            for (Runner runner in runners)
              ProviderScope(
                  overrides: [currentRunner.overrideWithValue(runner)],
                  child: const Forewarn())
          ],
        );
      } else {
        // first radio
        final controlId = disc.controls.keys.toList().first;
        final runners = ref.watch(runnerMapProvider).values.where((element) =>
            element.discipline.id == discId &&
            !element.radioPunches.containsKey(controlId) &&
            element.status == RunnerStatus.Unknown);
        return ListView(
          controller: ScrollController(),
          children: [
            for (Runner runner in runners)
              ProviderScope(
                  overrides: [currentRunner.overrideWithValue(runner)],
                  child: const Forewarn())
          ],
        );
      }
    }
  }
}
