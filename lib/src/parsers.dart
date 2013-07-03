part of rythm;

typedef Parser ToParser();

class RefParser extends Parser {

    ToParser _toParser;

    RefParser(this._toParser);

    Result parseOn(Context context) => _toParser().parseOn(context);

    Parser copy() => new RefParser(_toParser);
}

RefParser ref(ToParser p) => new RefParser(p);
