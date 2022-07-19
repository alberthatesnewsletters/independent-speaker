class RemoteControl {
  RemoteControl({required this.id, required this.name}) {
    isDeletion = false;
  }
  RemoteControl.forDeletion({required this.id, this.name = "DELETE"}) {
    isDeletion = true;
  }

  final int id;
  final String name;
  late final bool isDeletion;
}
