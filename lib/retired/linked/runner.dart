import '../../model/enums/country.dart';
import '../../model/enums/runner_status.dart';
import 'club.dart';
import 'control.dart';
import 'discipline.dart';

class LinkedRunner {
  String name;
  late LinkedClub club;
  late LinkedDiscipline discipline;
  Country country;
  String? numberBib;
  DateTime startTime;

  // do not blindly copy, check against discipline.controls
  // mispunches are kept in case they turn out to be correct
  // at which point, discipline.controls is updated
  Map<LinkedControl, Duration> radioTimes = {};

  Duration runningTime;
  RunnerStatus status;

  LinkedRunner(this.name, this.country, this.numberBib, this.startTime,
      this.runningTime, this.status);
}
