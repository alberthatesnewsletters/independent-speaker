import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Competition {
  const Competition(
      {required this.name,
      required this.date,
      required this.organizer,
      required this.homepage,
      required this.isPlaceholder});

  final String name;
  final DateTime date;
  final String organizer;
  final String homepage;
  final bool isPlaceholder;
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  String toString() {
    String thisComp = "";
    thisComp += "Name: ${name == "" ? "<Blank>" : name}\n";
    thisComp += "Date: ${formatter.format(date)}\n";
    thisComp += "Organizer: ${organizer == "" ? "<Blank>" : organizer}\n";
    thisComp += "Homepage: ${homepage == "" ? "<Blank>" : homepage}";

    return thisComp;
  }
}

class CompetitionInfo extends StateNotifier<Competition> {
  CompetitionInfo([Competition? initialComp])
      : super(initialComp ??
            Competition(
                name: "Placeholder",
                date: DateTime.now(),
                organizer: "Placeholder",
                homepage: "Placeholder",
                isPlaceholder: true));

  void overwrite(Competition newComp) {
    state = newComp;
  }
}
