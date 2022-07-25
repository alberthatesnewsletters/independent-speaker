import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/dataclasses/immutable/runner.dart';
import '../model/enums/sorting.dart';

class StartForewarn extends HookConsumerWidget {
  const StartForewarn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runner = ref.watch(currentRunner);

    return ListTile(
      title: Text(runner.name),
      subtitle: Text(DateTime.now().difference(runner.startTime).toString()),
    );
  }
}
