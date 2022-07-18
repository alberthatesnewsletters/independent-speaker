import 'package:attempt4/model/enums/country.dart';
import 'package:attempt4/retired/linked/runner.dart';

class LinkedClub {
  String name;
  Country country;
  final Set<LinkedRunner> runners = {};

  LinkedClub(this.name, this.country);
}
