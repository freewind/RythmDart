library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

class User {
  String name;
}

main() {

  final grammar = new RythmParser();

  test("sss", () {
    final start = grammar["start"];
    for (int i = 1;i <= 3;i++) {
      var file = new File("test/data/data${i}.txt");
      var content = file.readAsStringSync().replaceAll(r'\r\n|\r', '\n');
      var result = start.parse(content);
      print(result.value);
      print("---------------------------------");
    }
  });

//  group("start", () {
//    final start = grammar["start"];
//    test("hello world", () {
//      var s = start.parse("""
//      @args String who
//      Hello @who.capFirst()!
//      """);
//// just print for now
//      print(s);
//    });
//  });

//  group("args", () {
//    final args = grammar["args"];
//    test("1 arg", () {
//      expect(args.parse("@args String who").toString(), "Success[1:17]: [@args, [[String, who]]]");
//    });
//    test("2 args", () {
//      expect(args.parse("@args String who, String message").toString(), "Success[1:33]: [@args, [[String, who], [String, message]]]");
//    });
//    test("args with extra spaces", () {
//      expect(args.parse("@args    String    who  ,   \t String  \t\t  message ").toString(), "Success[1:51]: [@args, [[String, who], [String, message]]]");
//    });
//  });
//
//  group("invocation", () {
//    final invocation = grammar["invocation"];
//    test("@who", () {
//      expect(invocation.parse("@who").toString(), "Success[1:5]: [@, [[who, null]]]");
//    });
//    test("@aaa.bbb.ccc", () {
//      expect(invocation.parse("@aaa.bbb.ccc").toString(), "Success[1:13]: [@, [[aaa, null], [bbb, null], [ccc, null]]]");
//    });
//  });
//
//  group("test", () {
//    test("xxx", () {
//      var x = grammar["dart_str_single"];
//      var yyy = x.parse(r"""'ewdd"sfd\'fdf'""");
//      print(yyy);
//
//      var x1 = grammar["dart_str_double"];
//      var yyy1 = x1.parse(r'''"ewdd\"sfd'fdf"''');
//      print(yyy1);
//
//      var x2 = grammar["dart_str_triple_single"];
//      var yyy2 = x2.parse(r"""'''wef"ewf''wfe\"wef\'ewf''wef""wefef'''""");
//      print(yyy2);
//
//      var x3 = grammar["dart_str_triple_double"];
//      var yyy3 = x3.parse(r'''"""wef"ewf''wfe\"wef\'ewf''wef""wefef"""''');
//      print(yyy3);
//
//
//      var user1 = new User()..name = "Mike";
//      var user2 = new User()..name = "Jeff";
//      var user3 = new User()..name = "John}}}";
//      var users = [user1, user2, user3];
//      var x4 = grammar["expr"];
//      var yyy4 = x4.parse(readDartString("dart1.txt"));
//      print(yyy4.value);
//
//    });
//  });
}

//String readDartString(String name) {
//  File file = new File("test/data/$name");
//  return file.readAsStringSync();
//}


