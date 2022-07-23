import 'package:intl/intl.dart';

class Competition {
  Competition(
      {required this.name,
      required this.date,
      required this.organizer,
      required this.homepage});
  String name = "";
  DateTime date;
  String organizer = "";
  String homepage = "";
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

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
