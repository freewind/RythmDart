import "dart:isolate";

main() {
  spawnUri()
  var list = <String>[];
  list.add("aaa");
  list.add("bbb");
  print(list);
  list.remove("aaa");
  print(list);
}
