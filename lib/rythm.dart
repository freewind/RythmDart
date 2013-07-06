library rythm;

import "package:petitparser/petitparser.dart";
import "package:petitparser/beta.dart";
import "dart:collection";
import "dart:io";

part "src/parsers.dart";
part "src/parser.dart";
part "src/ast.dart";
part "src/compiler.dart";

String _tab(int level) {
    var sb = new StringBuffer();
    for (int i = 0;i < level; i++) {
        sb.write("  ");
    }
    return sb.toString();
}


void _fixString(Node node) {
    List<Node> nodes = [];
    StringBuffer sb = null;
    for (final Node item in node.children) {
//        print("item: [$item]");
        if (item is String) {
            if (sb == null) {
                sb = new StringBuffer(item);
            } else {
                sb.write(item);
            }
        } else {
            _fixString(item);
            if (sb != null) {
                nodes.add(new Plain(sb.toString()));
                sb = null;
            }
            nodes.add(item);
        }
    }
    if (sb != null) {
        nodes.add(new Plain(sb.toString()));
    }
    node.children = nodes;
}


String printTree(Node node) {
    _fixString(node);

    printNode(Node node, StringBuffer sb, int level) {
        inLine(String s) => s == null ? s : s.replaceAll('\n', r'\n');
        if (node.isLeaf) {
            sb.writeln('${_tab(level)}${node.runtimeType}(${inLine(node.content)})');
        } else {
            sb.writeln('${_tab(level)}${node.runtimeType}(${inLine(node.content)}');
            for (var child in node.children) {
                printNode(child, sb, level + 1);
            }
            sb.writeln('${_tab(level)})');
        }
    }

    var sb = new StringBuffer();
    printNode
    (
        node, sb, 0);
    return sb.toString();
}

_flatToStr(list) {
    if (list == null) return null;
    var sb = new StringBuffer();

    handleNode(node) {
        if (node is List) {
            for (var item in node) {
                handleNode(item);
            }
        } else {
            sb.write(node);
        }
    }
    handleNode(list);
    return sb . toString();

}
