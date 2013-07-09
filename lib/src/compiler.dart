part of rythm;

String _filename(String path) {
    return path.split("/").last.split(".").first;
}


class _Page {

    String mainFuncName;

    List<ImportDirective> imports;

    ExtendsDirective extendsDirective;

    EntryParamsDirective entryParams;

    RenderBody renderBody;

    List<Node> body;

    _Page(Document doc, this.mainFuncName) {
        this.imports = _removeNodes(doc, (node) => node is ImportDirective);
        this.extendsDirective = _singleOrNone(_removeNodes(doc, (node) => node is ExtendsDirective));
        this.entryParams = _singleOrNone(_removeNodes(doc, (node) => node is EntryParamsDirective));
        this.renderBody = doc.children.firstWhere((node) => node is RenderBody, orElse: () => null);
        this.body = doc.children;
        if (this.extendsDirective != null) {
            this.imports.add(new ImportDirective('"${extendsDirective.name.content}.dart"'));
        }
        if (this.renderBody != null) {
            if (this.entryParams == null) {
                this. entryParams = new EntryParamsDirective([]);
            }
            this.entryParams.args.add(new Param(new Name("String"), new Name("_renderBody(${renderBody.names})")));
        }
    }

    String toCode() {
        var cw = new CodeWriter();
        for (var item in imports) {
            item.toCode(cw);
        }

        cw.writeStmt("String ${mainFuncName} (");
        if (this.entryParams != null) {
            this.entryParams.toCode(cw);
        }
        cw.writeStmtLn(") {");

        if (extendsDirective != null) {
            cw.writeStmtLn("return ${extendsDirective.name.content}( () {");
        }

        cw.writeStmtLn("var ${cw.name} = new StringBuffer();");

        for (var item in body) {
            item.toCode(cw);
        }

        cw.writeStmtLn("return ${cw.name}.toString();");

        if (extendsDirective != null) {
            cw.writeStmtLn("});");
        }


        cw.writeStmtLn("}");
        return cw.toString();
    }

}


class Compiler {
    String compile(File file) {
        var parser = new RythmParser();
        var content = file.readAsStringSync();
        print("content: $content");

        var result = parser.start().parse(content);
        if (result is Success) {
            var document = result.value;
            printTree(document);
            _Page page = new _Page(document, _filename(file.path));
            return page.toCode();
        } else {
            return "failed!!!";
        }
    }
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

_singleOrNone(List<Node> nodes) {
    if (nodes.length > 1) {
        throw new Exception("The list of ${nodes.first.runtimeType} should have size of 0 or 1, but get: ${nodes.length}");
    }
    return nodes.isEmpty ? null : nodes.first;
}

