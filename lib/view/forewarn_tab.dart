import 'start_forewarn.dart';
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
      if (disc.controls.keys.length > 0) {
        final controlId = disc.controls.keys.last;
        return Text(
            "I AM THE FINISH HEHE AND THERE ARE RADIOS BEFORE ME $controlId");
      } else {
        final runners = ref.watch(runnerMapProvider).values.where((element) =>
            element.discipline.id == discId && !element.finishPunch.isPunched);
        return ListView(
          controller: ScrollController(),
          children: [
            for (Runner runner in runners)
              ProviderScope(
                  overrides: [currentRunner.overrideWithValue(runner)],
                  child: const StartForewarn())
          ],
        );
      }
    } else {
      final currentControl = ref.watch(currentControlId);
      final currentControlIndex =
          disc.controls.keys.toList().indexOf(currentControl);

      if (currentControlIndex != 0) {
        final controlId = disc.controls.keys
            .toList()[disc.controls.keys.toList().indexOf(currentControl) - 1];
        return const Text("I AM NOT THE FIRST AND NOT THE FINISH");
      } else {
        return const Text("I AM THE FIRST");
      }
    }
  }
}
