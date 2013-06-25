part of rythm;

class Node {

  List<Node> children = [];

  bool get isLeaf => children.isEmpty;

  void addChild(Node child) => children.add(child);

  String toCode(StringBuffer sb);

}

class Document extends Node {
  Document(List<Node> children) {
    children.forEach(addChild);
  }

  String toString() {
    var sb = new StringBuffer();
    sb.write("Document(");
    for (var child in children) {
      sb.write(child.toString());
    }
    sb.write(")");
    return sb.toString();
  }

  String toCode(StringBuffer sb) {
    var sb = new StringBuffer();
    sb.write('""');
    for (var child in children) {
      if (child is End) {
        // do nothing
      } else if (child is String) {
        sb.write('+"""');
        sb.write(child);
        sb.write('"""');
      } else {
        sb.write('+');
        child.toCode(sb);
      }
    }
    return sb.toString();
  }

  void removeNode(Node node) {
    children.remove(node);
  }
}

class Args extends Node {

  List<String> types = [];

  List<String> names = [];

  void add(String type, String name) {
    types.add(type);
    names.add(name);
  }

  String toString() => "Args(${sig()})";

  String sig() {
    var sb = new StringBuffer();
    for (int i = 0;i < types.length;i++) {
      if (i != 0) sb.write(", ");
      sb ..write(types[i])
      ..write(' ')
      ..write(names[i]);
    }
    return sb.toString();
  }

  String toCode(StringBuffer sb) => '""';

}

class Code extends Node {
  String content;

  Code(this.content);

  String toString() => "Code(${content})";

  String toCode(StringBuffer sb) {
    sb.write(content);
  }

}

class Plain extends Node {

  String content;

  Plain(this.content);

  String toString() => "Plain(${content})";

  String toCode(StringBuffer sb) {
    if (!content.contains("\n")) {
      if (!content.contains('"')) {
        sb..write('"')..write(content)..write('"');
        return sb.toString();
      } else if (!content.contains("'")) {
        sb..write("'")..write(content)..write("'");
        return sb.toString();
      }
    }
    if (!content.contains('"""')) {
      sb..write('"""')..write(content)..write('"""');
    } else if (!content.contains("'''")) {
      sb..write("'''")..write(content)..write("'''");
    } else {
      sb..write('"""')..write(content.replace('"""', r'\"""'))..write('"""');
    }
    return sb.toString();
  }
}

class End extends Node {
  String toString() => "End()";

  String toCode(StringBuffer sb) {
  }
}
