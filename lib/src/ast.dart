part of rythm;


class Node {

    String content = "";

    List<Node> children = [];

    Node();

    Node.withContent(this.content);

    Node.withChildren(this.children);

    bool get isLeaf => children.isEmpty;

    void toCode(StringBuffer sb) => sb.write(content);

    toString() => content;

}

class Document extends Node {

    Document(List<Node>children) {
        super.children = children;
    }

    String toCode(StringBuffer sb) {
        var sb = new StringBuffer();
        sb.write('""');
        for (var child in children) {
            if (child is String) {
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
}

class Import extends Node {
    String importPath;

    String as;

    Import(this.importPath, this.as) {
        super.content = importPath + (as == null ? '' : 'as $as');
    }
}

class IfElseIfElse extends Node {
    List<If> ifs;

    RythmBlock elseClause;

    IfElseIfElse(this.ifs, this.elseClause) {
        super.children..addAll(ifs)..add(elseClause);
    }
}

class If extends Node {
    String condition;

    If(this.condition, List<Node> children) : super.withChildren(children);
}


class FuncArgs extends Node {
    List<ArgItem> args;

    FuncArgs(this.args) {
        super.content = args.map((a) => a.content).join(", ");
    }

}

class EntryArgs extends FuncArgs {

    EntryArgs(List<ArgItem> args) :super(args);

}

class RythmExpr extends Node {
    List<Invocation> invocations;

    RythmExpr(this.invocations) {
        super.content = invocations.map((i) => i.content).join(".");
    }
}

class DartCode extends Node {

    DartCode(String content) :super.withContent(content);

}

class DartExpr extends Node {
    List<Invocation> invocations;

    DartExpr(this.invocations) {
        super.content = '\${' + invocations.map((i) => i.content).join(".") + '}';
    }
}

class Invocation extends Node {
    Name name;

    String params;

    Invocation(this.name, this.params) {
        super.content = name.content + (this.params == null ? "" : '($params)');
    }
}

class Plain extends Node {

    Plain(String content):super.withContent(content);

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
            sb..write('"""')..write(content.replaceAll('"""', r'\"""'))..write('"""');
        }
        return sb.toString();
    }

}


class DefFunc extends Node {
    String name;

    List<ArgItem> params;

    DefFunc(this.name, this.params, List<Node>body) {
        super.content = '$name(${params.map((p) => p.content).join(", ")})';
        super.children = body;
    }

}

class Name extends Node {
    Name(String content) :super.withContent(content);
}

class FuncInvocation extends Node {
    String funcName;

    String params;

    WithBody withBody;

    FuncInvocation(this.funcName, this.params, this.withBody);

}

class WithBody extends Node {
    String params;

    WithBody(this.params, List<Node> children) {
        super.content = this.params;
        super.children = children;
    }
}

class RythmComment extends Node {
    RythmComment(String content): super.withContent(content);
}

class Extends extends Node {
    String name;

    List<ArgItem> args;

    Extends(this.name, this.args) {
        super.content = "$name(${args.map((a) => a.content).join(', ')})";
    }

}

class RenderBody extends Node {
    List<Name> params;

    RenderBody(this.params) {
        super.content = params.map((a) => a.content).join(", ");
    }
}

class ArgItem extends Node {
    Name type;

    Name name;

    ArgItem(this.type, this.name) {
        super.content = '${type.content} ${name.content}';
    }

}

class Raw extends Node {
    Raw(String content) : super.withContent(content);
}

class For extends Node {
    Name varName;

    String list;

    RythmBlock body;

    RythmBlock elseClause;

    For(this.varName, this.list, this.body, this.elseClause) {
        super.content = 'var ${varName.content} in $list';
        super.children..add(body)..add(elseClause);
    }
}

class RythmBlock extends Node {

    RythmBlock(List<Node> children) :super.withChildren(children);

}

class Set extends Node {
    Name name;

    RythmBlock value;

    Set(this.name, this.value) {
        super.content = name.content;
        children.add(value);
    }
}

class Get extends Node {
    Name name;

    Get(this.name) {
        super.content = name.content;
    }
}

class Break extends Node {
    Break():super.withContent("break");
}

class Continue extends Node {
    Continue() : super.withContent("continue");
}

class Verbatim extends Node {
    Verbatim(String content) : super.withContent(content);
}

class I18n extends Node {
    Name name;

    I18n(this.name) {
        super.content = name.content;
    }
}

class Url extends Node {
    String action;

    Url(this.action) {
        super.content = action;
    }
}

class Include extends Node {
    String path;

    Include(this.path) {
        super.content = path;
    }
}

class None {
}
