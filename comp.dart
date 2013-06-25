import "lib/rythm.dart";
import "dart:collection";
import "dart:io";
import "dart:isolate";

main() {
  var compiler = new Compiler();
  var file = new File("test/data/data3.txt");
  String dart = compiler.compile(file);

  var out = new File("tmp/aaa.dart");
  out.writeAsString(dart).then((f) {
    var uri = f.path;
    ReceivePort port = new ReceivePort();
    port.receive((msg, _) {
      print(msg);
      port.close();
    });

    var ppp = spawnUri(uri);
    ppp.send(["Freewind", "Enjoy dart"], port.toSendPort());
  });
}
