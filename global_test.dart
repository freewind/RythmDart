import 'dart:isolate';

var g = 1;

echo() {
  port.receive((msg, reply) {
    reply.send('I received: $g');
  });
}

main() {
  var sendPort = spawnFunction(echo);

  void test() {
    g = 2;
    sendPort.call('Hello from main').then((reply) {
      print("I'm $g");
      print(reply);
      test();
    });
  }
  test();
}


