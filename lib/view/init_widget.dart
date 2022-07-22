import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../model/better_listener.dart';
import '../model/remotes/meos/connection.dart';
import '../model/remotes/meos/reader.dart';
import 'base_widget.dart';

class InitWidget extends HookConsumerWidget {
  const InitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = MeOSconnection();
    final listener = BetterListener(clubMapProvider, controlMapProvider,
        disciplineMapProvider, runnerMapProvider, ref);
    final reader = MeOSreader(conn, listener);
    reader.run();
    //return const Text("Hello world!");

    return const BaseWidget();
  }
}
