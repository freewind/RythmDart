library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

main() {

    final parser = new RythmParser();

    parse(String str) => printTree(parser.start().parse(str).value);

    group("@args", () {
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

    group("@aaa", () {
        test("@aaa", () {
            expect(parse("@aaa"), 'Document(\n'
            '  RythmExpr(aaa)\n'
            ')\n');
        });
        test("@aaa.bbb", () {
            expect(parse("@aaa.bbb"), 'Document(\n'
            '  RythmExpr(aaa.bbb)\n'
            ')\n');
        });
        test("@aaa().bbb()", () {
            expect(parse("@aaa().bbb()"), 'Document(\n'
            '  RythmExpr(aaa().bbb())\n'
            ')\n');
        });
        test("@aaa().bbb((x)=>x*x)", () {
            expect(parse("@aaa().bbb((x)=>x*x)"), 'Document(\n'
            '  RythmExpr(aaa().bbb((x)=>x*x))\n'
            ')\n');
        });
    });

    group("@(...)", () {
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


    group("@def", () {
        test("simplest", () {
            expect(parse("@def hello() {}"), 'Document(\n'
            '  DefFunc(hello())\n'
            ')\n');
        });
        test("one param", () {
            expect(parse("@def hello(String name) {}"), 'Document(\n'
            '  DefFunc(hello(String name))\n'
            ')\n');
        });
        test("two params", () {
            expect(parse("@def hello(String name, int age) {}"), 'Document(\n'
            '  DefFunc(hello(String name, int age))\n'
            ')\n');
        });
        test("have body", () {
            expect(parse("""
@def hello(String name) {
    Hello, @name
}
"""), 'Document(\n'
            '  DefFunc(hello(String name)\n'
            '    Plain(Hello, )\n'
            '    RythmExpr(name)\n'
            '    Plain(\\n)\n'
            '  )\n'
            ')\n');
        });
    });

    group("@hello() withBody (...){}", () {
        test("no params", () {
            expect(parse("@hello() withBody { abc }"), 'Document(\n'
            '  CallFuncWithBody(hello() withBody \n'
            '    Plain(abc )\n'
            '  )\n'
            ')\n');
        });
        test("0 param", () {
            expect(parse("@hello() withBody () { abc }"), 'Document(\n'
            '  CallFuncWithBody(hello() withBody ()\n'
            '    Plain(abc )\n'
            '  )\n'
            ')\n');
        });
        test("one param", () {
            expect(parse("@hello() withBody (a) { abc }"), 'Document(\n'
            '  CallFuncWithBody(hello() withBody (a)\n'
            '    Plain(abc )\n'
            '  )\n'
            ')\n');
        });
        test("two params", () {
            expect(parse("@hello() withBody (a , b) { abc }"), 'Document(\n'
            '  CallFuncWithBody(hello() withBody (a, b)\n'
            '    Plain(abc )\n'
            '  )\n'
            ')\n');
        });
    });

    group("dartCode", () {
        test("simple", () {
            expect(parse(r"@{ var x = '111'; }"), 'Document(\n'
            '  DartCode( var x = \'111\'; )\n'
            ')\n');
        });
        test("multiLine", () {
            expect(parse("""@{
dartString() => (
    ref(dartStrTripleDouble)
    | ref(dartStrTripleSingle)
    | ref(dartStrSingle)
    | ref(dartStrDouble)
);
}"""), 'Document(\n'
            '  DartCode(\\ndartString() => (\\n    ref(dartStrTripleDouble)\\n    | ref(dartStrTripleSingle)\\n    | ref(dartStrSingle)\\n    | ref(dartStrDouble)\\n);\\n)\n'
            ')\n');

        });
    });

}


