library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";

main() {

  final grammar = new RythmGrammar();

  group("args", () {
    final args = grammar["args"];
    test("1 arg", () {
      expect(args.parse("@args String who").value, ["@args", [["String", "who"]]]);
    });
    test("2 args", () {
      expect(args.parse("@args String who, String message").value, ["@args", [["String", "who"], ["String", "message"]]]);
    });
  });
}
