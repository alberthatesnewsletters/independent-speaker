class RemoteControl {
  final int id;
  final String name;
  final bool isDeletion;

  RemoteControl(
      {required this.id, required this.name, this.isDeletion = false});
  RemoteControl.forDeletion(
      {required this.id, this.name = "DELETE", this.isDeletion = true});
}
