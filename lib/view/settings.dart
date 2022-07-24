import 'package:attempt4/main.dart';
import 'package:attempt4/model/remotes/meos/reader.dart';

import '../backend.dart';
import '../model/better_listener.dart';
import '../model/dataclasses/immutable/competition.dart';
import '../model/remotes/meos/connection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static const routeName = "/settings";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingState();
}

class _SettingState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    final disciplines = ref.watch(disciplineMapProvider).values.toList();
    final competition = ref.watch(competitionInfoProvider);

    return Scaffold(
      body: Column(
        children: competition.isPlaceholder
            ? [const Center(child: CircularProgressIndicator())]
            : [
                Text(competition.name),
                Expanded(
                  child: ListView.builder(
                    itemCount: disciplines.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                          title: Text(disciplines[index].name),
                          tileColor: disciplines[index].isFollowed
                              ? Colors.green
                              : Colors.white,
                          onTap: () => disciplines[index].isFollowed
                              ? ref
                                  .read(disciplineMapProvider.notifier)
                                  .unfollow(disciplines[index].id)
                              : ref
                                  .read(disciplineMapProvider.notifier)
                                  .follow(disciplines[index].id));
                    }),
                  ),
                ),
                ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, "basewidget"),
                    child: const Text("Let's go")),
              ],
      ),
    );
  }
}
