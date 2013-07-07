part of rythm;


class Node {
    String content = "";

    List<Node> children = [];

    Node();

    Node.withContent(this.content);

    Node.withChildren(this.children);

    bool get isLeaf => children.isEmpty;

    void toCode(CodeWriter sb) => sb.write(content);

    toString() => content;
}

class Document extends Node {

    Document(List<Node>children) {
        super.children = children;
    }

    String toCode(CodeWriter sb) {
        for (var child in children) {
            child.toCode(sb);
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

    void toCode(CodeWriter sb) {
        if (as == null) {
            sb.writeln("import $importPath;");
        } else {
            sb.writeln("import $importPath as $as;");
        }
    }
}

class IfElseDirective extends Node {
    List<If> ifs;

    RythmBlock elseClause;

    IfElseDirective(this.ifs, this.elseClause) {
        super.children..addAll(ifs);
        if (elseClause != null) {
            super.children.add(elseClause);
        }
    }

    void toCode(CodeWriter sb) {
        for (int i = 0;i < ifs.length;i++) {
            If ifClause = ifs[i];
            if (i > 0) {
                sb.write(" else ");
            }
            ifClause.toCode(sb);
        }
        if (!elseClause.isLeaf) {
            elseClause.write(sb);
        }
    }
}

class If extends Node {
    String condition;

    RythmBlock body;

    If(_condition, this.body) {
        this.condition = _condition.trim();
        super.content = this.condition;
        super.children = [body];
    }

    void toCode(CodeWriter sb) {
        sb.write("if ($condition) ");
        body.toCode(sb);
    }
}


class FuncParams extends Node {
    List<Param> args;

    FuncParams(this.args) {
        super.content = args.map((a) => a.content).join(", ");
    }

    void toCode(CodeWriter sb) {
        for (int i = 0;i < args.length;i++) {
            Param p = args[i];
            if (i > 0) {
                sb.write(", ");
            }
            p.toCode(sb);
        }
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

class PlainLine extends Plain {
    PlainLine(String line): super(line);

    void toCode(CodeWriter sb) {
        sb.writeEscapedLn(content);
    }
}

class Plain extends Node {

    Plain(String content):super.withContent(content);

    String toCode(CodeWriter sb) {
        sb.writeEscaped(content);
    }
}


class DefFuncDirective extends Node {
    Name name;

    List<Param> params;

    RythmBlock body;

    DefFuncDirective(this.name, this.params, this.body) {
        if (params == null) params = [];
        super.content = '${name.content}(${params.map((p) => p.content).join(", ")})';
        super.children = [body];
    }

    void toCode(CodeWriter sb) {
        name.write("(");
        super.toCode(sb);
        name.write(")");
        body.toCode(sb);
    }

}

class CallFuncWithBodyDirective extends Node {
    Name name;

    String params;

    List<Name> bodyParams;

    RythmBlock body;

    CallFuncWithBodyDirective(this.name, this.params, this.bodyParams, this.body) {
        super.content = '${name.content}($params) withBody'
        + (bodyParams == null ? "" : ' (${bodyParams.map((p) => p.content).join(", ")})');
        super.children = [body];
    }
}

class Name extends Node {
    Name(String content) :super.withContent(content);
}

class ExtendsDirective extends Node {
    String name;

    List<NamedArg> get args => children;

    ExtendsDirective(this.name, List<NamedArg> args) {
        super.children = args;
        super.content = "$name";
    }

}

class NamedArg extends Node {
    Name name;

    get value => this.children;

    NamedArg(this.name, value) {
        this.children = value;
        super.content = "${name.content}";
    }
}

class RenderBody extends Node {
    List<Name> args;

    RenderBody(this.args) {
        super.content = names;
    }

    get names => args == null ? "" : args.map((a) => a.content).join(", ");

    void toCode(CodeWriter sb) {
        sb.writeln("_renderBody(${names})");
    }

}

class RenderDirective extends Node {
    RenderDirective(InvocationChain chain) :super.withChildren([chain]);

    RenderDirective.callWithBody(CallFuncWithBodyDirective callFunc) :super.withChildren([callFunc]);
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
        super.children..add(body);
        if (this.elseClause != null) {
            super.children.add(elseClause);
        }
    }
}

class RythmBlock extends Node {

    RythmBlock(List<Node> children) {
        if (children != null && !children.isEmpty) {
            super.children = children;
        }
    }

    RythmBlock.empty(): this(null);
}

class SetDirective extends NamedArg {
    SetDirective(namedArg): super(namedArg.name, namedArg.value);
}

class GetDirective extends Node {
    String name;

    GetDirective(this.name) {
        super.content = name;
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

class None extends Node {
}

