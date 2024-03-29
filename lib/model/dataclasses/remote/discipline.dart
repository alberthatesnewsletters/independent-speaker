/// an orienteering class, but naming a class Class risks confusion

class RemoteDiscipline {
  RemoteDiscipline(
      {required this.id, required this.name, required this.controls}) {
    isDeletion = false;
  }

  RemoteDiscipline.forDeletion(
      {required this.id, this.name = "DELETE", this.controls = const []}) {
    isDeletion = true;
  }

  final int id;
  final String name;
  final List<int> controls;
  late final bool isDeletion;
}
