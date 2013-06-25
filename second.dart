import "dart:isolate";

String hello(String who, String message) {
  return "Hello, $who, $message";
}

main() {
  port.receive((msg, reply) => reply.send(hello(msg[0], msg[1])));
}
