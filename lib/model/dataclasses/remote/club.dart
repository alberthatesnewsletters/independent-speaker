import 'package:attempt4/model/enums/country.dart';

class RemoteClub {
  final int id;
  final String name;
  final Country country;
  final bool isDeletion;

  RemoteClub(
      {required this.id,
      required this.name,
      required this.country,
      this.isDeletion = false});

  RemoteClub.forDeletion(
      {required this.id,
      this.name = "DELETE",
      this.country = Country.None,
      this.isDeletion = true});
}
