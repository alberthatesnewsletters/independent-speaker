// import 'package:attempt4/model/enums/country.dart';
// import 'package:attempt4/retired/linked/runner.dart';

// import '../../model/competition.dart';
// import '../../model/dataclasses/remote/club.dart';
// import '../../model/dataclasses/remote/control.dart';
// import '../../model/dataclasses/remote/discipline.dart';
// import '../../model/dataclasses/remote/runner.dart';
// import 'club.dart';
// import 'control.dart';
// import 'discipline.dart';

// class WorseListener {
//   final Map<int, LinkedClub> _clubs = {};
//   final Map<int, LinkedControl> _controls = {};
//   final Map<int, LinkedDiscipline> _disciplines = {};
//   final Map<int, LinkedRunner> _runners = {};
//   final _noClub = LinkedClub("No Club", Country.None);

//   void printAll() {
//     int count = 1;
//     print("CLUBS");
//     print("#####################");
//     for (LinkedClub club in _clubs.values) {
//       print("$count. ${club.name}");
//       print("Runners:");
//       for (LinkedRunner runner in club.runners) {
//         print(runner.name);
//       }
//       count++;
//     }

//     count = 1;
//     print("CONTROLS");
//     print("#####################");
//     for (LinkedControl control in _controls.values) {
//       print("$count. ${control.name} | Classes: ${control.disciplines.length}");
//       count++;
//     }

//     count = 1;
//     print("DISCIPLINES");
//     print("#####################");
//     for (LinkedDiscipline discipline in _disciplines.values) {
//       print("$count. ${discipline.name}");
//       print("Controls: ${discipline.controls.length}");
//       for (LinkedControl control in discipline.controls) {
//         print(control.name);
//       }
//       count++;
//     }

//     count = 1;
//     print("RUNNERS");
//     print("#####################");
//     for (LinkedRunner runner in _runners.values) {
//       print(
//           "$count. ${runner.name} | Class: ${runner.discipline.name} | Club: ${runner.club.name}");
//       count++;
//     }
//   }

//   DateTime _determineStartTime(int milliseconds) {
//     return Competition.date!.add(Duration(milliseconds: milliseconds));
//   }

//   void _tempControl(LinkedDiscipline discipline, int controlId) {
//     final fixControl = LinkedControl("<<PLACEHOLDER>>");
//     fixControl.disciplines.add(discipline);
//     discipline.controls.add(fixControl);
//     _controls[controlId] = fixControl;
//   }

//   void _tempClub(LinkedRunner runner, int clubId) {
//     final fixClub = LinkedClub("<<PLACEHOLDER>>", Country.None);
//     fixClub.runners.add(runner);
//     runner.club = fixClub;
//     _clubs[clubId] = fixClub;
//   }

//   void _tempDiscipline(LinkedRunner runner, int discId) {
//     final fixDiscipline = LinkedDiscipline("<<PLACEHOLDER>>");
//     fixDiscipline.runners.add(runner);
//     runner.discipline = fixDiscipline;
//     _disciplines[discId] = fixDiscipline;
//   }

// // TODO: automatically clearing the controls might fuck with the frontend
// // but, objects are kept intact
// // bigger TODO we need to verify the radio times when we remove controls
// // also what if someone has punched at a previously-wrong control?
//   void _discControlCheck(RemoteDiscipline incoming, LinkedDiscipline existing) {
//     for (LinkedControl control in existing.controls) {
//       control.disciplines.remove(existing);
//     }
//     existing.controls.clear();
//     List<int> toMatch = [...incoming.controls];
//     for (int properControl in toMatch) {
//       if (_controls.containsKey(properControl)) {
//         _controls[properControl]!.disciplines.add(existing);
//         existing.controls.add(_controls[properControl]!);
//       } else {
//         _tempControl(existing, properControl);
//       }
//     }
//   }

//   void updateClubs(List<RemoteClub> updates) {
//     for (RemoteClub incoming in updates) {
//       if (_clubs.containsKey(incoming.id)) {
//         _clubs[incoming.id]!.name = incoming.name;
//         _clubs[incoming.id]!.country = incoming.country;
//       } else {
//         _clubs[incoming.id] = (LinkedClub(incoming.name, incoming.country));
//       }
//     }
//   }

//   void updateControls(List<RemoteControl> updates) {
//     for (RemoteControl incoming in updates) {
//       if (_controls.containsKey(incoming.id)) {
//         _controls[incoming.id]!.name = incoming.name;
//       } else {
//         _controls[incoming.id] = LinkedControl(incoming.name);
//       }
//     }
//   }

//   void updateDisciplines(List<RemoteDiscipline> updates) {
//     for (RemoteDiscipline incoming in updates) {
//       if (_disciplines.containsKey(incoming.id)) {
//         _disciplines[incoming.id]!.name = incoming.name;
//         _discControlCheck(incoming, _disciplines[incoming.id]!);
//       } else {
//         final newDiscipline = LinkedDiscipline(incoming.name);
//         for (int newControl in incoming.controls) {
//           if (_controls.containsKey(newControl)) {
//             newDiscipline.controls.add(_controls[newControl]!);
//             _controls[newControl]!.disciplines.add(newDiscipline);
//           } else {
//             _tempControl(newDiscipline, newControl);
//           }
//         }
//         _disciplines[incoming.id] = newDiscipline;
//       }
//     }
//   }

//   void _determineClub(LinkedRunner runner, int clubId, bool isNew) {
//     if (_clubs.containsKey(clubId)) {
//       if (!isNew) {
//         runner.club.runners.remove(runner);
//       }
//       runner.club = _clubs[clubId]!;
//       runner.club.runners.add(runner);
//     } else {
//       _tempClub(runner, clubId);
//     }
//   }

//   void _determineDiscipline(LinkedRunner runner, int discId, bool isNew) {
//     if (_disciplines.containsKey(discId)) {
//       if (!isNew) {
//         runner.discipline.runners.remove(runner);
//       }
//       runner.discipline = _disciplines[discId]!;
//       runner.discipline.runners.add(runner);
//     } else {
//       _tempDiscipline(runner, discId);
//     }
//   }

//   Duration _determineRunningTime(int milliseconds) {
//     return Duration(milliseconds: milliseconds);
//   }

//   // TODO communicate news value
//   void _inspectRadioTimes(LinkedRunner runner, Map<int, int> newTimes) {
//     for (int registeredPunch in newTimes.keys) {
//       // remote spaghetti protection
//       if (!_controls.containsKey(registeredPunch)) {
//         _controls[registeredPunch] = LinkedControl("<<PLACEHOLDER>>");
//       }

//       // 1: we only care to inspect the punch if it belongs to the class
//       if (runner.discipline.controls.contains(_controls[registeredPunch])) {
//         if (!runner.radioTimes.containsKey(_controls[registeredPunch])) {
//           // news value, new punch
//         } else if (runner.radioTimes[_controls[registeredPunch]] !=
//             Duration(milliseconds: newTimes[registeredPunch]!)) {
//           // news value if the time is updated
//         }
//       }

//       // 2: but we add it no matter what. could be administrative error
//       runner.radioTimes[_controls[registeredPunch]!] =
//           Duration(milliseconds: newTimes[registeredPunch]!);
//     }
//   }

//   void updateRunners(List<RemoteRunner> updates) {
//     for (RemoteRunner incoming in updates) {
//       final startTime = _determineStartTime(incoming.startTime);
//       final runningTime = _determineRunningTime(incoming.runningTime);

//       if (runningTime.inMilliseconds > 0) {
//         // TODO news value
//       }

//       if (_runners.containsKey(incoming.id)) {
//         LinkedRunner existing = _runners[incoming.id]!;

//         existing.name = incoming.name;
//         existing.country = incoming.country;
//         existing.numberBib = incoming.numberBib;
//         existing.startTime = startTime;

//         if (existing.status != incoming.status) {
//           existing.status = incoming.status;
//           // TODO alert. big deal.
//         }

//         if (incoming.hasNoClub) {
//           existing.club = _noClub;
//           _noClub.runners.add(existing);
//         } else {
//           if (existing.club != _clubs[incoming.clubId]) {
//             _determineClub(existing, incoming.clubId, false);
//           }
//         }

//         if (existing.discipline != _disciplines[incoming.discId]) {
//           _determineDiscipline(existing, incoming.discId, false);
//         }

//         _inspectRadioTimes(existing, incoming.radioTimes);
//       } else {
//         final newRunner = LinkedRunner(incoming.name, incoming.country,
//             incoming.numberBib, startTime, runningTime, incoming.status);

//         // TODO maybe there is smoother logic
//         if (incoming.hasNoClub) {
//           if (!_clubs.containsValue(_noClub)) {
//             _clubs[incoming.clubId] = _noClub;
//           }
//           newRunner.club = _noClub;
//           _noClub.runners.add(newRunner);
//         } else {
//           _determineClub(newRunner, incoming.clubId, true);
//         }

//         _determineDiscipline(newRunner, incoming.discId, true);
//         _inspectRadioTimes(newRunner, incoming.radioTimes);

//         _runners[incoming.id] = newRunner;
//       }
//     }
//   }
// }
