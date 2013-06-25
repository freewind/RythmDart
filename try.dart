import "lib/rythm.dart";
import "dart:collection";
import "dart:io";
import "dart:isolate";

class User {
  String name;
}

main() {

  var compiler = new Compiler();
  Directory dataDir = new Directory("test/data");
  dataDir.list(recursive:true).listen((f) {
    if (f is File) {
      String dart = compiler.compile(f);
      print(dart);
    }
  });


}
