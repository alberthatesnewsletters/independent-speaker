import 'package:attempt4/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'finish_punches.dart';

class AllRunnersTab extends ConsumerWidget {
  const AllRunnersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRunners = ref
        .watch(runnerMapProvider)
        .values
        .where((element) => element.finishPunch.isPunched)
        .toList();

    allRunners.sort(
        (a, b) => a.finishPunch.punchedAt.compareTo(b.finishPunch.punchedAt));

    return Column(
      children: [
        TextButton(
            onPressed: () =>
                ref.read(runnerMapProvider.notifier).markFinishReadAll(),
            child: const Text("Mark all as read")),
        Expanded(
          child: ListView(
            controller: ScrollController(),
            children: [
              for (final runner in allRunners)
                ProviderScope(
                    overrides: [currentRunner.overrideWithValue(runner)],
                    child: const RunnerFinishItem())
            ],
          ),
        ),
      ],
    );
  }
}
