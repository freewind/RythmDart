library test_grammar;

import "package:unittest/unittest.dart";
import "../lib/rythm.dart";
import "dart:io";

main() {

    initParserExtension();

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
    testFile("rythm_comment.txt");
    testFile("def.txt");
    testFile("dart_code.txt");

}


