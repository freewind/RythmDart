part of rythm;

class CodeWriter {

    String name;

    bool usePrefix = false;

    final StringBuffer sb = new StringBuffer();

    CodeWriter(this.name) ;

    void writeln([String line = ""]) {
        if (usePrefix) {
            sb.write(name);
            sb.write('.writeln ( ');
            sb.write(line);
            sb.writeln(');');
        } else {
            sb.writeln(line);
        }
    }

    void write(String str) {
        if (usePrefix) {
            sb.write(name);
            sb.write('.write   ( ');
            sb.write(str);
            sb.writeln(');');
        } else {
            sb.write(str);
        }
    }

    void writeEscaped(String str) {
        if (usePrefix) {
            sb.write(name);
            sb.write('.write    (r');
            sb.write(_escape(str));
            sb.writeln(');');
        } else {
            sb.writeln(_escape(str));
        }

    }

    void writeEscapedLn(String str) {
        if (usePrefix) {
            sb.write(name);
            sb.write('.writeln (r');
            sb.write(_escape(str));
            sb.writeln(');');
        } else {
            sb.writeln(_escape(str));
        }
    }

    toString() => sb.toString();

    String _escape(String str) {
        if (!str.contains('"')) {
            return '"' + str + '"';
        } else if (!str.contains("'")) {
            return "'" + str + "'";
        } else {
            return "'" + str.replaceAll("'", "\'") + "'";
        }
    }

}
