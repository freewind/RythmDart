import 'package:unittest/unittest.dart';
import "test_grammar.dart" as test_grammar;

main() {
    testCore(new Configuration());
}

void testCore(Configuration config) {
    unittestConfiguration = config;
    groupSep = ' - ';

    group("grammar", test_grammar.main);
}
