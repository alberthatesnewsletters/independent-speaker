import 'dart:developer';

import 'package:xml/xml.dart';

import '../../better_listener.dart';
import '../../competition.dart';
import '../../dataclasses/remote/club.dart';
import '../../dataclasses/remote/control.dart';
import '../../dataclasses/remote/discipline.dart';
import '../../dataclasses/remote/runner.dart';
import '../../enums/runner_status.dart';
import 'connection.dart';
import '../../../utils.dart';
import '../../enums/country.dart';

class MeOSreader {
  final MeOSconnection _conn;
  final BetterListener _listener;
  int _fullLoads = 0;
  int _errors = 0;

  static const Map<String, Country> _countryMap = {
    "SWE": Country.Sweden,
  };

  static const Map<int, RunnerStatus> _statusMap = {
    0: RunnerStatus.Unknown,
    1: RunnerStatus.Ok,
    2: RunnerStatus.OkNoTime,
    3: RunnerStatus.MissingPunch,
    4: RunnerStatus.DidNotFinish,
    5: RunnerStatus.Disqualified,
    6: RunnerStatus.Overtime,
    15: RunnerStatus.OutOfCompetition,
    20: RunnerStatus.DidNotStart,
    21: RunnerStatus.Cancelled,
    99: RunnerStatus.NotParticipating
  };

  MeOSreader(this._conn, this._listener);

  void _wipeLists() {
    _listener.wipeInfo();
  }

  void _setCompetition(XmlElement compInfo) {
    try {
      // TODO replace forcegets with gets and handle null
      Competition.name = compInfo.text;
      Competition.date = DateTime.tryParse(compInfo.forceGetAttribute("date"));
      Competition.organizer = compInfo.forceGetAttribute("organizer");
      Competition.homepage = compInfo.forceGetAttribute("homepage");
      print("Competition info parsed");
      print(Competition.date);
    } on Exception catch (e) {
      log(e.toString());
      return;
    }
  }

  Country _determineCountry(String? country) {
    if (country == null) {
      return Country.None;
    } else if (_countryMap.containsKey(country)) {
      return _countryMap[country]!;
    } else {
      log("Received unknown country code: $country");
      return Country.Unknown;
    }
  }

  RunnerStatus _determineStatus(int status) {
    if (_statusMap.containsKey(status)) {
      return _statusMap[status]!;
    } else {
      log("Received unknown status code: $status");
      return RunnerStatus.Unknown;
    }
  }

  List<int> _parseDisciplineRadios(String radios) {
    final List<int> allRadios = [];

    if (radios.isNotEmpty) {
      for (String singleRadio in radios.split(",")) {
        allRadios.add(int.parse(singleRadio)); // TODO error handling
      }
    }

    return allRadios;
  }

  Map<int, int> _parseRunnerRadios(String? radios) {
    final Map<int, int> allRadios = radios == null
        ? {}
        : {
            for (String e in radios.split(";"))
              int.parse(e.split(",")[0]):
                  100 * int.parse(e.split(",")[1]) // TODO error handling
          };

    return allRadios;
  }

  RemoteClub? _parseClub(XmlElement clubInfo) {
    try {
      final id = int.parse(clubInfo.forceGetAttribute("id"));

      if (clubInfo.getAttribute("delete") == "true") {
        return RemoteClub.forDeletion(id: id);
      } else {
        final name = clubInfo.text;
        final country = _determineCountry(clubInfo.getAttribute("nat"));

        return RemoteClub(id: id, name: name, country: country);
      }
    } on Exception catch (e) {
      log(e.toString());
      _errors++;
      return null;
    }
  }

  RemoteControl? _parseControl(XmlElement controlInfo) {
    try {
      final id = int.parse(controlInfo.forceGetAttribute("id"));

      if (controlInfo.getAttribute("delete") == "true") {
        return RemoteControl.forDeletion(id: id);
      } else {
        final name = controlInfo.text;

        return RemoteControl(id: id, name: name);
      }
    } on Exception catch (e) {
      log(e.toString());
      _errors++;
      return null;
    }
  }

  RemoteDiscipline? _parseDiscipline(XmlElement discInfo) {
    try {
      final id = int.parse(discInfo.forceGetAttribute("id"));

      // MeOS sends a MOPComplete if a class is deleted, so this is more of a speculative measure
      if (discInfo.getAttribute("delete") == "true") {
        return RemoteDiscipline.forDeletion(id: id);
      } else {
        final name = discInfo.text;
        final controls =
            _parseDisciplineRadios(discInfo.forceGetAttribute("radio"));

        return RemoteDiscipline(id: id, name: name, controls: controls);
      }
    } on Exception catch (e) {
      log(e.toString());
      _errors++;
      return null;
    }
  }

  RemoteRunner? _parseRunner(XmlElement runnerInfo) {
    try {
      final id = int.parse(runnerInfo.forceGetAttribute("id"));

      if (runnerInfo.getAttribute("delete") == "true") {
        return RemoteRunner.forDeletion(id: id);
      } else {
        final radioTimes = _parseRunnerRadios(
            runnerInfo.getElement("radio") == null
                ? null
                : runnerInfo.getElement("radio")!.text);

        final XmlElement furtherInfo = runnerInfo.forceGetElement("base");

        final name = furtherInfo.text;
        final clubId = int.parse(furtherInfo.forceGetAttribute("org"));
        final discId = int.parse(furtherInfo.forceGetAttribute("cls"));
        final numberBib = furtherInfo.getAttribute("bib");
        final status =
            _determineStatus(int.parse(furtherInfo.forceGetAttribute("stat")));
        final startTime = 100 * int.parse(furtherInfo.forceGetAttribute("st"));
        final runningTime =
            100 * int.parse(furtherInfo.forceGetAttribute("rt"));
        final country = _determineCountry(furtherInfo.getAttribute("nat"));
        final hasNoClub = clubId == 0;

        return RemoteRunner(
            id: id,
            name: name,
            clubId: clubId,
            discId: discId,
            country: country,
            numberBib: numberBib,
            startTime: startTime,
            radioTimes: radioTimes,
            runningTime: runningTime,
            isFinished: runningTime != 0,
            status: status,
            hasNoClub: hasNoClub);
      }
    } on Exception catch (e) {
      log(e.toString());
      _errors++;
      return null;
    }
  }

  void _updateClubs(Iterable<XmlElement> clubInfo) {
    final clubs =
        clubInfo.map((e) => _parseClub(e)).whereType<RemoteClub>().toList();

    if (clubs.isNotEmpty) {
      print("Clubs: ${clubs.length}");
    }
    _listener.processClubs(clubs);
  }

  void _updateControls(Iterable<XmlElement> controlInfo) {
    final controls = controlInfo
        .map((e) => _parseControl(e))
        .whereType<RemoteControl>()
        .toList();

    if (controls.isNotEmpty) {
      print("Controls: ${controls.length}");
    }
    _listener.processControls(controls);
  }

  void _updateDisciplines(Iterable<XmlElement> discInfo) {
    final disciplines = discInfo
        .map((e) => _parseDiscipline(e))
        .whereType<RemoteDiscipline>()
        .toList();

    if (disciplines.isNotEmpty) {
      print("Disciplines: ${disciplines.length}");
    }
    _listener.processDisciplines(disciplines);
  }

  void _updateRunners(Iterable<XmlElement> runnerInfo) {
    final runners = runnerInfo
        .map((e) => _parseRunner(e))
        .whereType<RemoteRunner>()
        .toList();

    if (runners.isNotEmpty) {
      print("Runners: ${runners.length}");
    }
    _listener.processRunners(runners);
  }

  Future<void> _parseUpdates() async {
    final XmlDocument update =
        await _conn.getDifference(previousSuccessful: _errors == 0);

    _errors = 0;

    final clubs = update.findAllElements("org");
    final controls = update.findAllElements("ctrl");
    final disciplines = update.findAllElements("cls");
    final runners = update.findAllElements("cmp");

    if (update.getElement("MOPComplete") != null) {
      _wipeLists();
      _fullLoads++;

      XmlElement compInfo =
          update.forceGetElement("MOPComplete").forceGetElement("competition");

      _setCompetition(compInfo);
    } else if (update.getElement("MOPDiff") == null) {
      print("Server is being incomprehensible");
      return;
    }

    // IN. THIS. ORDER.
    // clubs & controls -> disciplines -> runners
    // if you jumble it, the listener will be wasting effort on editing placeholders
    // disciplines rely on controls; runners rely on all the other three
    // changing the order is a good robustness check though

    _updateClubs(clubs);
    _updateControls(controls);
    _updateDisciplines(disciplines);
    _updateRunners(runners);

    //print("Errors: $_errors");
    //_printClubs();
  }

  Future<void> run() async {
    //await _parseUpdates();
    while (true) {
      await _parseUpdates();
      await Future.delayed(Duration(milliseconds: Utils.updateWaitMs));
    }
  }
}
