library test_files;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

String _readFile(String filename) {
  return new File("test/data/$filename").readAsStringSync();
}

main() {
  parseFile(String filename) => new RythmParser().start().parse(_readFile(filename)).value.toString();

  test("args.txt", () {
    expect(parseFile("args.txt"), """Document(Args(String who, String message)Plain(<html>
<body>
<div>Hello, )Code(who)Plain(, )Code(message.toLowerCase())Plain(</div>
</body>
</html>
))""");
  });

  test("args_multiline.txt", () {
    expect(parseFile("args_multiline.txt"), """Document(Args(String who, String message)Plain(<html>
<body>
<div>Hello, )Code(who)Plain(, )Code(message.toLowerCase())Plain(</div>
</body>
</html>
))""");
  });

  test("def.txt", () {
    expect(parseFile("def.txt"), """xxx""");
  });

}
