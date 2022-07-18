/// an orienteering class, but naming a class Class risks confusion

class RemoteDiscipline {
  final int id;
  final String name;
  final List<int> controls;
  final bool isDeletion;

  RemoteDiscipline(
      {required this.id,
      required this.name,
      required this.controls,
      this.isDeletion = false});

  RemoteDiscipline.forDeletion(
      {required this.id,
      this.name = "DELETE",
      this.controls = const [],
      this.isDeletion = true});
}
