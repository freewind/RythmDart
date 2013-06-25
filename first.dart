import "dart:isolate";

main() {
  ReceivePort port = new ReceivePort();
  port.receive((msg, _) {
    print(msg);
    port.close();
  });
  var c = spawnUri("./second.dart");
  c.send(["Freewind", "enjoy dart"], port.toSendPort());
}
