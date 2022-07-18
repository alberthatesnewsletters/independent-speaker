import 'package:attempt4/retired/linked/runner.dart';

import 'control.dart';

class LinkedDiscipline {
  String name;
  final Set<LinkedControl> controls = {};
  final Set<LinkedRunner> runners = {};
  bool isFollowed = false;

  LinkedDiscipline(this.name);
}
