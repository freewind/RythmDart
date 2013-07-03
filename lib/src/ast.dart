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

class ImportDirective extends Node {
    String importPath;

    String as;

    ImportDirective(this.importPath, this.as) {
        super.content = importPath + (as == null ? '' : 'as $as');
    }
}

class IfElseDirective extends Node {
    List<If> ifs;

    RythmBlock elseClause;

    IfElseDirective(this.ifs, this.elseClause) {
        super.children..addAll(ifs)..add(elseClause);
    }
}

class If extends Node {
    String condition;

    If(this.condition, List<Node> children) : super.withChildren(children);
}


class FuncParams extends Node {
    List<Param> args;

    FuncParams(this.args) {
        super.content = args.map((a) => a.content).join(", ");
    }

}

class EntryParamsDirective extends FuncParams {

    EntryParamsDirective(List<Param> args) :super(args);

}

class InvocationChain extends Node {
    List<Invocation> invocations;

    InvocationChain(this.invocations) {
        super.content = invocations.map((i) => i.content).join(".");
    }
}


class DartCode extends Node {

    DartCode(String content) :super.withContent(content);

}

class DartEmbedExpr extends Node {
    List<Invocation> invocations;

    DartEmbedExpr(this.invocations) {
        super.content = '\${' + invocations.map((i) => i.content).join(".") + '}';
    }
}

class Invocation extends Node {
    Invocation(value):super.withContent(value);
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


class DefFuncDirective extends Node {
    Name name;

    List<Param> params;

    DefFuncDirective(this.name, this.params, List<Node>body) {
        if (params == null) params = [];
        super.content = '${name.content}(${params.map((p) => p.content).join(", ")})';
        super.children = body;
    }

}

class CallFuncWithBodyDirective extends Node {
    Name name;

    String params;

    List<Name> bodyParams;

    List<Node> body;

    CallFuncWithBodyDirective(this.name, this.params, this.bodyParams, this.body) {
        super.content = '${name.content}($params) withBody '
        + (bodyParams == null ? "" : '(${bodyParams.map((p) => p.content).join(", ")})');
        super.children = body;
    }
}

class Name extends Node {
    Name(String content) :super.withContent(content);
}

class ExtendsDirective extends Node {
    String name;

    List<NamedArg> args;

    ExtendsDirective(this.name, this.args) {
        super.content = "$name(${args.map((a) => a.content).join(', ')})";
    }

}

class NamedArg extends Node {
    Name name;

    String value;

    NamedArg(this.name, this.value) {
        super.content = "${name.content}=$value";
    }
}

class RenderBody extends Node {
    List<Name> args;

    RenderBody(this.args) {
        super.content = args == null ? "" : args.map((a) => a.content).join(", ");
    }
}

class Param extends Node {
    Name type;

    Name name;

    Param(this.type, this.name) {
        super.content = '${type.content} ${name.content}';
    }
}

class RawDirective extends Node {
    RawDirective(String content) : super.withContent(content);
}

class ForDirective extends Node {
    Name varName;

    String list;

    RythmBlock body;

    RythmBlock elseClause;

    ForDirective(this.varName, this.list, this.body, this.elseClause) {
        super.content = 'var ${varName.content} in $list';
        super.children..add(body)..add(elseClause);
    }
}

class RythmBlock extends Node {

    RythmBlock(List<Node> children) :super.withChildren(children);

}

class SetDirective extends Node {
    Name name;

    RythmBlock value;

    SetDirective(this.name, this.value) {
        super.content = name.content;
        children.add(value);
    }
}

class GetDirective extends Node {
    Name name;

    GetDirective(this.name) {
        super.content = name.content;
    }
}

class Break extends Node {
    Break():super.withContent("break");
}

class Continue extends Node {
    Continue() : super.withContent("continue");
}

class VerbatimDirective extends Node {
    VerbatimDirective(String content) : super.withContent(content);
}

class I18nDirective extends Node {
    Name name;

    I18nDirective(this.name) {
        super.content = name.content;
    }
}

class UrlDirective extends Node {
    String action;

    UrlDirective(this.action) {
        super.content = action;
    }
}

class IncludeDirective extends Node {
    String path;

    IncludeDirective(this.path) {
        super.content = path;
    }
}

class DartLiteral extends Node {
    DartLiteral(value) :super.withContent(value);
}

class RythmComment extends Node {
    RythmComment(value) :super.withContent(value);
}

class None {
}

