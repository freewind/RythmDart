part of rythm;

class Compiler {
    String compile(File file) {
        var parser = new RythmParser();
        var content = file.readAsStringSync();
        print("content: $content");

        var result = parser.start().parse(content);
        if (result is Success) {
            var document = result.value;
            print("### print tree");
            printTree(document);
            print("### print tree end");
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

    var sb = new CodeWriter("xxx");

// import
    var list = _removeNodes(doc, (node) => node is ImportDirective);
    for (var item in list) {
        sb.usePrefix = false;
        item.toCode(sb);
    }

// direct @renderBody
    RenderBody renderBodyDirective = doc.children.firstWhere((node) => node is RenderBody, orElse: () => null);

// extends
    list = _removeNodes(doc, (node) => node is ExtendsDirective);
    print("#### ExtendsDirective list: $list, list.length: ${list.length}");
    ExtendsDirective extendsDirective = null;

    if (list.length == 1) {
        extendsDirective = list[0];
        sb.writeln('import "${extendsDirective.name}.dart";');
    } else if (list.length > 1) {
        throw new Exception("found more than 1 extendsDirective");
    }

// entryParamsDirective
    list = _removeNodes(doc, (node) => node is EntryParamsDirective);
    print("#### EntryParamsDirective list: $list, list.length: ${list.length}");
    EntryParamsDirective entryParamsDirective = null;
    if (list.length > 1) {
        throw new Exception("Can't have more than one EntryParamsDirective in a template: " + list.length);
    } else if (list.length == 1) {
        entryParamsDirective = list[0];
    }

    sb.usePrefix = false;
    sb.write("String ${filename(file.path)} (");
    print("### entryParamsDirective: $entryParamsDirective");
    if (entryParamsDirective != null) {
        entryParamsDirective.toCode(sb);
    }
    if (entryParamsDirective != null && renderBodyDirective != null) {
        sb.write(", ");
    }
    if (renderBodyDirective != null) {
        sb.write("String _renderBody(${renderBodyDirective.names})");
    }
    sb.writeln(") {");

    if(extendsDirective!=null) {
        sb.writeln("return ${extendsDirective.name}( () {");
    }

    // content this current page
    sb.writeln("var ${sb.name} = new StringBuffer();");
    sb.usePrefix = true;
    doc.toCode(sb);
    sb.usePrefix = false;
    sb.writeln("return ${sb.name}.toString();");

    if(extendsDirective!=null) {
        sb.writeln("});");
    }


    sb.writeln("}");

    return sb.toString();


//    var temp = """
//    import "dart:isolate";
//    String ${filename(file.path)}(${params()}) {
//        return ${doc.toCode(new StringBuffer())};
//    }
//
//    main() {
//      port.receive((msg, reply) => reply.send(${filename(file.path)}(msg[0], msg[1])));
//    }
//  """;
//    return temp;
}

List<Node> _removeNodes(Document doc, bool test(Node)) {
    var matched = [];
    var nodes = [doc];
    for (int i = 0;i < nodes.length;i++) {
        var node = nodes[i];
        if (!node.isLeaf) {
            nodes.addAll(node.children);
        }
        if (test(node)) {
            matched.add(node);
        }
    }

// remove
    print(matched);

    _remove(Node node) {
        if (!node.isLeaf) {
            node.children.removeWhere((elem) => matched.contains(elem));
            for (var child in node.children) {
                _remove(child);
            }
        }
    }
    _remove(doc);

    return matched;
}
