part of rythm;

class Compiler {
    String compile(File file) {
        var parser = new RythmParser();
        var result = parser.parse(file.readAsStringSync());
        if (result is Success) {
            var document = result.value;
            return _compile(file, document);
        } else {
            return "failed!!!";
        }
    }
}

String _compile(File file, Document doc) {
    String filename(String path) {
        return path.split("/").last.split(".").first;
    }

    String params() {
        var first = doc.children[0];
        if (first is EntryArgs) {
            doc.children.removeAt(0);
            return first.sig();
        } else {
            return "";
        }
    }
    var temp = """
    import "dart:isolate";
    String ${filename(file.path)}(${params()}) {
        return ${doc.toCode(new StringBuffer())};
    }
      
    main() {
      port.receive((msg, reply) => reply.send(${filename(file.path)}(msg[0], msg[1])));
    }
  """;
    return temp;
}
