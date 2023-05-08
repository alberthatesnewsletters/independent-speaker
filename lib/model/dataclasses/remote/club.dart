import 'package:attempt4/model/enums/country.dart';

class RemoteClub {
  RemoteClub({required this.id, required this.name, required this.country}) {
    isDeletion = false;
  }

  RemoteClub.forDeletion(
      {required this.id, this.name = "DELETE", this.country = Country.None}) {
    isDeletion = true;
  }

  final int id;
  final String name;
  final Country country;
  late final bool isDeletion;
}
