library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

main() {

    final _parser = new RythmParser();

    _parse(String str) => printTree(_parser.start().parse(str).value);

    _checkFile(String filename) {
        var file = new File('test/data/$filename');
        var content = file.readAsStringSync();
        var items = content.split(new RegExp("[-]{10}[-]+"));
        var ori = items[0].trim();
        var ast = items[1].trim();
        expect(_parse(ori).trim(), ast);
    }

    testFile(String filename) {
        test(filename, () {
            _checkFile(filename);
        });
    }


    testFile("entry_params.txt");
    testFile("invocation_chain.txt");
    testFile("invocation_chain_with_parenthesis.txt");
    testFile("rythm_comment.txt");
    testFile("def.txt");
    testFile("dart_code.txt");
    testFile("dart_comment.txt");
    testFile("dart_string.txt");
    testFile("extends.txt");
    testFile("call_func_with_body.txt");
    testFile("if_else.txt");
    testFile("for.txt");
    testFile("verbatim.txt");
    testFile("get.txt");
    testFile("set.txt");
    testFile("import.txt");
    testFile("include.txt");
    testFile("render.txt");
    testFile("at_at.txt");
}
