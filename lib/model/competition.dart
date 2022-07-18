// TODO pass around instead of global

import 'package:intl/intl.dart';

class Competition {
  static String name = "";
  static DateTime? date;
  static String organizer = "";
  static String homepage = "";
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');

  static String toStringStatic() {
    String thisComp = "";
    thisComp += "Name: ${name == "" ? "<Blank>" : name}\n";
    thisComp += "Date: $onlyDate\n";
    thisComp += "Organizer: ${organizer == "" ? "<Blank>" : organizer}\n";
    thisComp += "Homepage: ${homepage == "" ? "<Blank>" : homepage}";

    return thisComp;
  }

  static String get onlyDate =>
      (date == null ? "<Blank>" : formatter.format(date!));
}
