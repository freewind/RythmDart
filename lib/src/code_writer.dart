part of rythm;

class CodeWriter {

    String name;

    final StringBuffer sb = new StringBuffer();

    CodeWriter([this.name = "sb"]) ;

    void writeStmt(String stmt) {
        sb.write(stmt);
    }

    void writeStmtLn(String stmt) {
        sb.writeln(stmt);
    }

    void writeExprLn(String expr) {
        sb.write(name);
        sb.write('.writeln ( ');
        sb.write(expr);
        sb.writeln(');');
    }

    void writeExpr(String expr) {
        sb.write(name);
        sb.write('.write   ( ');
        sb.write(expr);
        sb.writeln(');');
    }

    void writeStr(String str) {
        sb.write(name);
        sb.write('.write    (r');
        sb.write(_escape(str));
        sb.writeln(');');
    }

    void writeStrLn(String str) {
        sb.write(name);
        sb.write('.writeln (r');
        sb.write(_escape(str));
        sb.writeln(');');
    }

    toString() => sb.toString();

    String _escape(String str) {
        if (!str.contains('"')) {
            return '"' + str + '"';
        } else if (!str.contains("'")) {
            return "'" + str + "'";
        } else {
            return "'" + str.replaceAll(new RegExp("'"), r"\'") + "'";
        }
    }

}
