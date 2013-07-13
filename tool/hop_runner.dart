library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import '../test/test_all.dart' as test;
import '../lib/rythm.dart';

void main() {
    addTask('test', createUnitTestTask(test.testCore));

    addTask('docs', createDartDocTask(_getLibs, linkApi: true));

    addTask('rythm', createCompileRythmTask());

    runHop();
}

Future<List<String>> _getLibs() {
    return new Directory('lib').list()
    .where((FileSystemEntity fse) => fse is File)
    .map((File file) => file.path)
    .toList();
}


Task createCompileRythmTask() {
    return new Task.sync((TaskContext ctx) {
        String filename(File f) {
            var path = f.path;
            return path.split("/").last.split(".").first;
        }
        var templates = new Directory("test/templates");
        var compiler = new Compiler();
        templates.list(recursive:false).listen((f) {
            if (f is File) {
                print("compiling: ${f}");
                String dart = compiler.compile(f);
                print(dart);
                var target = new File("tmp/${filename(f)}.dart");
                target.writeAsStringSync(dart);
            }
        });
        return true;
    });
}
