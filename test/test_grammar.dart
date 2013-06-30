library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

main() {

    final parser = new RythmParser();

    parse(String str) => printTree(parser.start().parse(str).value);

    group("args", () {
        test("singleLine", () {
            expect(parse("@args String name"), 'Document(\n'
            '  EntryArgs(String name)\n'
            ')\n');
            expect(parse("@args String name, int age"), 'Document(\n'
            '  EntryArgs(String name, int age)\n'
            ')\n');
            expect(parse("@args ( String name, int age)"), 'Document(\n'
            '  EntryArgs(String name, int age)\n'
            ')\n');
        });
        test("multiLine", () {
            expect(parse('@args ('
            '   String name,'
            '   int age'
            ')'), 'Document(\n'
            '  EntryArgs(String name, int age)\n'
            ')\n');
        });
    });

    group("dartComments", () {
        test("singleLine", () {
            expect(parse(r"@{//dwef ewf// ewf\n}"), 'Document(\n'
            '  DartCode(//dwef ewf// ewf\\n)\n'
            ')\n');
        });
        test("multiLine", () {
            expect(parse("""@{/*dwef* ewf// ewf*/}"""), 'Document(\n'
            '  DartCode(/*dwef* ewf// ewf*/)\n'
            ')\n');
            expect(parse("""@{/**dwef* ewf// ewf*/}"""), 'Document(\n'
            '  DartCode(/**dwef* ewf// ewf*/)\n'
            ')\n');
            expect(parse("""@{/**\n* dwef* ewf//\ne wf*/}"""), 'Document(\n'
            '  DartCode(/**\\n* dwef* ewf//\\ne wf*/)\n'
            ')\n');
        });
    });

    group("dartString", () {
        test("'...'", () {
            expect(parse("@{'weflwdfwe'}"), 'Document(\n'
            '  DartCode(\'weflwdfwe\')\n'
            ')\n');
            expect(parse(r"@{'wef${sss}lwdfwe'}"), 'Document(\n'
            '  DartCode(\'wef\${sss}lwdfwe\')\n'
            ')\n');
        });
        test('"..."', () {
            expect(parse('@{"weflwdfwe"}'), 'Document(\n'
            '  DartCode("weflwdfwe")\n'
            ')\n');
            expect(parse('@{"wef\${sss}lwdfwe"}'), 'Document(\n'
            '  DartCode("wef\${sss}lwdfwe")\n'
            ')\n');
        });
        test('"""..."""', () {
            expect(parse('''@{"""dswf""wefwef"wefwef\${ds}
dfsdf"""}'''), 'Document(\n'
            '  DartCode("""dswf""wefwef"wefwef\${ds}\\ndfsdf""")\n'
            ')\n');
        });
        test("'''...'''", () {
            expect(parse("""@{'''hello\${ds}
dart'''}"""), 'Document(\n'
            "  DartCode('''hello\${ds}\\ndart''')\n"
            ')\n');
        });
    });

    group("(...)", () {
        test("singleLine", () {
            expect(parse('@(abc)'), 'Document(\n'
            '  RythmExpr(abc)\n'
            ')\n');
            expect(parse('@(abc())'), 'Document(\n'
            '  RythmExpr(abc())\n'
            ')\n');
            expect(parse('@(abc(()=>{return "xx";}))'), 'Document(\n'
            '  RythmExpr(abc(()=>{return "xx";}))\n'
            ')\n');
        });
        test("multiLine", () {
            expect(parse('@(abc\n.xyz)'), 'Document(\n'
            '  RythmExpr(abc.xyz)\n'
            ')\n');
            expect(parse('@(abc(\n))'), 'Document(\n'
            '  RythmExpr(abc(\\n))\n'
            ')\n');
            expect(parse('@(abc(\n()=>{return "xx";}))'), 'Document(\n'
            '  RythmExpr(abc(\\n()=>{return "xx";}))\n'
            ')\n');
        });
    });

//  group("{...}", () {
//    test("singleLine", () {
//      expect(parse('{abc}'), '{abc}');
//      expect(parse('{abc{}}'), '{abc{}}');
//      expect(parse('{abc()}'), '{abc()}');
//    });
//    test("multiLine", () {
//      expect(parse('{ab\nc}'), '{ab\nc}');
//      expect(parse('{abc{\n}}'), '{abc{\n}}');
//      expect(parse('{abc(\n)}'), '{abc(\n)}');
//    });
//  });
//
//  group("@def", () {
//    test("def", () {
//      expect(parse("""
//@def hello(String name) {
//    Hello, @name
//}
//"""), """Def(hello(String name){
//    Hello, Code(name)
//}""");
//    });
//  });

//	group("dartCode", () {
//		test("has single line comment", () {
//			expect(parse(r"@{//dwef ewf// ewf\n}"), 'Document(\n'
//			'  DartCode(//dwef ewf// ewf\\n)\n'
//			')\n');
//		});
//	});

}


