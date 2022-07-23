import 'package:attempt4/main.dart';
import 'package:attempt4/model/remotes/meos/reader.dart';

import '../model/better_listener.dart';
import '../model/competition.dart';
import '../model/remotes/meos/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  static const routeName = "/settings";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conn = ModalRoute.of(context)!.settings.arguments as MeOSconnection;
    final competition = Competition(
        name: "Placeholder",
        date: DateTime.now(),
        organizer: "Placeholder",
        homepage: "Placeholder");
    final listener = BetterListener(
        clubs: clubMapProvider,
        controls: controlMapProvider,
        disciplines: disciplineMapProvider,
        runners: runnerMapProvider,
        competition: competition,
        ref: ref);
    final reader = MeOSreader(conn, listener, competition);
    bool isLoading = true;

    Future<void> initialize() async {
      await reader.initialize();
      isLoading = false;
    }

    initialize();
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const Text("hello world"),
    );
  }
}
