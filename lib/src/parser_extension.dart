part of rythm;

whitespaceInLine() => char('\n').neg().and().seq(whitespace());

class ParserExtension {

    until(Parser self, newParser) {
        var realNewParser = newParser;
        if (newParser is String) {
            realNewParser = newParser.length == 1 ? char(newParser) : string(newParser);
        }
        return self.seq(realNewParser.neg().star()).seq(realNewParser);
    }

    untilInLine(Parser self, Parser newParser) => self.seq(newParser.or(char('\n')).neg().star()).seq(newParser);

    untilSame(Parser self) => until(self, self);

    untilSameInLine(Parser self) => untilInLine(self, self);

    trimLeft(Parser self, [Parser trimmer]) => new _TrimmingLeftParser(self, trimmer == null ? whitespace() : trimmer);

    trimRight(Parser self, [Parser trimmer]) => new _TrimmingRightParser(self, trimmer == null ? whitespace() : trimmer);

    trimRightInLine(Parser self) => trimRight(self, whitespaceInLine());

    trimInLine(Parser self) => trimRight(trimLeft(self, whitespaceInLine()), whitespaceInLine());

}

class _TrimmingLeftParser extends Parser {

    Parser parser;

    Parser _trimmer;

    _TrimmingLeftParser(this.parser, this._trimmer);

    Result parseOn(Context context) {
        var current = context;
        do {
            current = _trimmer.parseOn(current);
        } while (current.isSuccess);
        return parser.parseOn(current);
    }

    Parser copy() => new _TrimmingLeftParser(parser, _trimmer);

    List<Parser> get children => [parser, _trimmer];

    void replace(Parser source, Parser target) {
        super.replace(source, target);
        if (_trimmer == source) {
            _trimmer = target;
        }
    }

}

class _TrimmingRightParser extends Parser {

    Parser parser;

    Parser _trimmer;

    _TrimmingRightParser(this.parser, this._trimmer);


    Result parseOn(Context context) {
        var result = parser.parseOn(context);
        if (result.isFailure) {
            return result;
        }
        var current = result;
        do {
            current = _trimmer.parseOn(current);
        } while (current.isSuccess);
        return current.success(result.value);
    }

    Parser copy() => new _TrimmingRightParser(parser, _trimmer);

    List<Parser> get children => [parser, _trimmer];

    void replace(Parser source, Parser target) {
        super.replace(source, target);
        if (_trimmer == source) {
            _trimmer = target;
        }
    }

}

