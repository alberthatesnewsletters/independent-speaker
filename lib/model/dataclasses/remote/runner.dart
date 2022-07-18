import 'package:attempt4/model/enums/country.dart';

import '../../enums/runner_status.dart';

class RemoteRunner {
  final int id;
  final String name;
  final int clubId;
  final int discId;
  final Country country;
  final String? numberBib;
  final int startTime; // milliseconds past 00:00 of the event day
  final Map<int, int> radioTimes; // <controlId, milliseconds>
  final int runningTime; // a duration in milliseconds
  final RunnerStatus status;
  final bool hasNoClub;
  final bool isDeletion;

  RemoteRunner(
      {required this.id,
      required this.name,
      required this.clubId,
      required this.discId,
      required this.country,
      required this.numberBib,
      required this.startTime,
      required this.radioTimes,
      required this.runningTime,
      required this.status,
      required this.hasNoClub,
      this.isDeletion = false});

  RemoteRunner.forDeletion(
      {required this.id,
      this.name = "DELETE",
      this.clubId = 0,
      this.discId = 0,
      this.country = Country.None,
      this.numberBib = "DELETE",
      this.startTime = 0,
      this.radioTimes = const {},
      this.runningTime = 0,
      this.status = RunnerStatus.Cancelled,
      this.hasNoClub = true,
      this.isDeletion = true});
}
