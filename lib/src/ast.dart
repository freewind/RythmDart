part of rythm;


class Node {

    String content = "";

    List<Node> children = [];

    Node();

    Node.withContent(this.content);

    Node.withChildren(this.children);

    bool get isLeaf => children.isEmpty;

    void toCode(CodeWriter cw) => cw.writeExprLn(content);

    toString() => "${this.runtimeType}: $content";
}

class Document extends Node {

    Document(List<Node>children) {
        super.children = children;
    }

    void toCode(CodeWriter cw) {
        for (var child in children) {
            child.toCode(cw);
        }
    }
}

class ImportDirective extends Node {
    String importPath;

    String as;

    ImportDirective(this.importPath, [this.as=null]) {
        super.content = importPath + (as == null ? '' : 'as $as');
    }

    void toCode(CodeWriter cw) {
        if (as == null) {
            cw.writeStmtLn("import $importPath;");
        } else {
            cw.writeStmtLn("import $importPath as $as;");
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

    void toCode(CodeWriter cw) {
        for (int i = 0;i < ifs.length;i++) {
            If ifClause = ifs[i];
            if (i > 0) {
                cw.writeStmt(" else ");
            }
            ifClause.toCode(cw);
        }
        if (elseClause != null && !elseClause.isLeaf) {
            elseClause.toCode(cw);
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

    void toCode(CodeWriter cw) {
        cw.writeStmtLn("if ($condition) {");
        body.toCode(cw);
        cw.writeStmtLn("}");
    }
}


class FuncParams extends Node {
    List<Param> args;

    FuncParams(this.args) {
        super.content = args.map((a) => a.content).join(", ");
    }

    void toCode(CodeWriter cw) {
        for (int i = 0;i < args.length;i++) {
            Param p = args[i];
            if (i > 0) {
                cw.writeStmt(", ");
            }
            p.toCode(cw);
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

    void toCode(CodeWriter cw) {
        cw.writeStmtLn("try {");
        cw.writeExpr(content);
        cw.writeStmtLn("} catch(e) {");
        cw.writeStmtLn("}");
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

    void toCode(CodeWriter cw) {
        cw.writeStrLn(content);
    }
}

class Plain extends Node {

    Plain(String content):super.withContent(content);

    void toCode(CodeWriter cw) {
        cw.writeStr(content);
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
    Name name;

    List<NamedArg> get args => children;

    ExtendsDirective(this.name, List<NamedArg> args) {
        super.children = args;
        super.content = name.content;
    }

}

class NamedArg extends Node {
    Name name;

    get value => this.children;

    NamedArg(this.name, value) {
        this.children = value;
        super.content = name.content;
    }
}

class RenderBody extends Node {
    List<Name> args;

    RenderBody(this.args) {
        super.content = names;
    }

    get names => args == null ? "" : args.map((a) => a.content).join(", ");

    void toCode(CodeWriter cw) {
        cw.writeExprLn("_renderBody(${names})");
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

    void toCode(CodeWriter cw) {
        cw.writeStmt(content);
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

    void toCode(CodeWriter cw) {
        var flagName = _nextVarName();
        if (elseClause != null) {
            cw.writeStmtLn("var $flagName = false;");
        }
        var itemName = varName.content;
        var index = _nextVarName();
        cw.writeStmtLn("var $index = 0;");
        cw.writeStmtLn("for ($content) {");
        cw.writeStmtLn("var ${itemName}_index = $index;");
        cw.writeStmtLn("var ${itemName}_isFirst = $index == 0;");
        cw.writeStmtLn("var ${itemName}_isLast = $index == ${list}.length-1;");
        cw.writeStmtLn("var ${itemName}_isOdd = $index%2==1;");
        cw.writeStmtLn("var ${itemName}_isEven = $index%2==0;");

        if (elseClause != null) {
            cw.writeStmtLn("$flagName = true;");
        }
        body.toCode(cw);
        cw.writeStmtLn("$index += 1;");
        cw.writeStmtLn("}");

        if (elseClause != null) {
            cw.writeStmtLn("if($flagName) {");
            elseClause.toCode(cw);
            cw.writeStmtLn("}");
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

    void toCode(CodeWriter cw) {
        for (var child in children) {
            child.toCode(cw);
        }
    }
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

    void toCode(CodeWriter cw) {
        cw.writeStmtLn("break;");
    }
}

class Continue extends Node {
    Continue() : super.withContent("continue");

    void toCode(CodeWriter cw) {
        cw.writeStmtLn("continue;");
    }
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

