part of rythm;

class RythmParser {

    final PARAMS = string("@params").trimRightInLine();

    final IMPORT = string("@import").trimInLine();

    final INCLUDE = string("@include");

    final RENDER = string("@render");

    final IF = string("@if").trimRightInLine();

    final ELSE = string("else").trimInLine();

    final BREAK = string("@break");

    final CONTINUE = string("@continue");

    final DEF = string("@def").trimRightInLine();

    final EXTENDS = string("@extends").trimInLine();

    final RENDER_BODY = string("@renderBody");

    final GET = string("@get");

    final SET = string("@set");

    final FOR = string("@for");

    final VERBATIM = string("@verbatim");

    final VAR = string("var");

    final IN = string("in");

    final AS = string("as");

    final WITH_BODY = string("withBody");

    final NL = string("\n").optional("");

// @params String name, int age

    html() => any();

    name() => word().plus().flatten()
    .map((each) => new Name(each));

    relaxedName() => (word() | anyIn('-.')).plus().flatten()
    .map((each) => new Name(each));

    entryParams() => (
        PARAMS
        & (
            ref(paramListWithParenthesis).pick(1)
            | ref(paramList)
        )
        & NL
    ).pick(1)
    .map((each) => new EntryParamsDirective(each));

    paramList() => (
        ref(paramItem).separatedBy(char(','), includeSeparators:false)
    );

    paramItem() => (
        ref(name).trim()
        & ref(name).trim()
    ).map((each) => new Param(each[0], each[1]));

    paramListWithParenthesis() => (
        char('(')
        & ref(paramList).optional()
        & char(')')
    );

// @import "dart:xxx"

    importDirective() => (
        IMPORT
        & char('"').untilSameInLine().trimInLine().flatten()
        & (
            AS.trimInLine() &
            ref(name)
        ).pick(1).optional()
        & NL
    ).permute([1, 2])
    .map((each) => new ImportDirective(each[0], each[1] == null ? null : each[1].content));

// @if(...) {} else if(...) {} else {}

    ifElseDirective() => (
        IF &
        ref(ifClause).separatedBy(
            (ELSE.trimInLine() & string("if").trimInLine()),
            includeSeparators:false)
        &
        (
            ELSE.trimInLine()
            & ref(blockTextWithRythmExpr).trimInLine()
        ).pick(1).optional()
    ).permute([1, 2])
    .map((each) => new IfElseDirective(each[0], each[1] == null ? null : each[1]));

    ifClause() => (
        ref(blockParenthesis).pick(1).trimInLine()
        & ref(blockTextWithRythmExpr).trimInLine()
    )
    .map((each) => new If(_flatToStr(each[0]), each[1]));

    forDirective() => (
        FOR
        & (
            char('(')
            & ref(forClause)
            & char(')')
        ).trimInLine().pick(1)
        & ref(blockTextWithRythmExpr)
        & (
            ELSE
            & ref(blockTextWithRythmExpr)
        ).pick(1).optional()
    ).permute([1, 2, 3])
    .map((each) => new ForDirective(each[0][0], each[0][1], each[1], each[2]));

    forClause() => (
        VAR.trimInLine()
        & ref(name)
        & IN.trimInLine()
        & ref(invocationChain).flatten()
    ).permute([1, 3]);

    extendsDirective() => (
        EXTENDS
        & ref(name).trim()
        & (
            char('(')
            & ref(namedArgItem).separatedBy(char(',').trim(), includeSeparators: false)
            & char(')')
            & NL
        ).pick(1).optional([])
    ).permute([1, 2])
    .map((each) => new ExtendsDirective(each[0], each[1]));

    namedArgItem() => (
        ref(relaxedName)
        & char('=').trimInLine()
        & ref(simpleRythmExpr)
    ).map((each) {
        var value = each[2];
        value = value is List ? value : [value];
        return new NamedArg(each[0], value);
    });

    renderBody() => (
        RENDER_BODY
        & (
            char('(')
            & ref(name).trim().separatedBy(char(','), includeSeparators:false)
            & char(')')
        ).pick(1).optional()
    ).pick(1).map((each) => new RenderBody(each));

    renderDirective() => (
        RENDER.trimRightInLine()
        &
        (
            ref(_callFuncWithBody)
            | ref(invocationChain)
        )
        & NL
    ).pick(1)
    .map((each) {
        if (each is List) {
            return new RenderDirective(new InvocationChain(each));
        } else {
            return new RenderDirective.callWithBody(each);
        }
    });

    callFuncWithBody() => (
        char('@')
        & ref(_callFuncWithBody)
    ).pick(1);

    _callFuncWithBody() => (
        ref(name)
        & ref(blockParenthesis).pick(1)
        & WITH_BODY.trimInLine()
        & (
            char('(')
            & ref(name).separatedBy(char(',').trim(), includeSeparators:false).optional([])
            & char(')').trimInLine()
        ).pick(1).optional()
        & ref(blockTextWithRythmExpr)
    ).map((each) => new CallFuncWithBodyDirective(each[0], _flatToStr(each[1]), each[3], each[4]));

    invocationChain() => (
        ref(invocationItem).separatedBy(char('.'), includeSeparators:false)
    );

    invocationChainWithSpaces() => (
        ref(invocationItem).trim().separatedBy(char('.'), includeSeparators:false)
    );

    invocationItem() => (
        ref(name)
        & ref(blockParenthesis).optional("")
    )
    .map((each) => new Invocation(_flatToStr(each)));

    rythmComment() => (
        string("@*").untilString("*@")
    ).pick(1)
    .map((each) => new RythmComment(each.join()));


    plainBlock() => char('{') & ref(plain) & char('}');


    plain() => (ref(blockBrace) | ref(html)).star();


    start() => ref(document).end();


    document() => (
        whitespace()
        | ref(rythmComment)
        | ref(importDirective)
        | ref(extendsDirective)
        | ref(entryParams)
        | ref(renderDirective)
        | ref(defFuncDirective)
        | ref(renderBody)
        | ref(getDirective)
        | ref(setDirective)
        | ref(includeDirective)
        | ref(renderDirective)
        | ref(callFuncWithBody)
        | ref(ifElseDirective)
        | ref(forDirective)
        | ref(verbatimDirective)
        | ref(dartCode)
        | ref(dartExpr)
        | ref(rythmExpr)
        | ref(html)
    ).star()
    .map((each) => _createDocument(each));

    dartCode() => (
        char('@')
        & ref(blockBrace).pick(2)
        & NL
    ).pick(1)
    .map((each) {
        return new DartCode(_flatToStr(each));
    });

    rythmExpr() => (
        char(r"@")
        & (
            ref(invocationChain)
            | (
                char('(')
                & ref(invocationChainWithSpaces)
                & char(')')
                & NL
            ) .pick(1)
        )
    ).pick(1)
    .map((each) => new InvocationChain(each));

    dartExpr() => (
        char(r"$")
        & (
            ref(invocationChain)
            | (char('{') & ref(invocationChain) & char('}')).pick(1)
        )
    ).pick(1)
    .map((each) => new DartEmbedExpr(each));

    simpleRythmExpr() => (
        ref(dartString)
        | ref(dartNumber)
        | ref(dartBoolean)
        | ref(invocationChain)
        | ref(blockTextWithRythmExpr)
    );

    dartString() => (
        ref(dartStrTripleDouble)
        | ref(dartStrTripleSingle)
        | ref(dartStrSingle)
        | ref(dartStrDouble)
        | ref(dartRawString)
    ).flatten();

    dartNumber() => (
        digit().plus()
        & (
            char('.')
            & digit().plus()
        ).optional()
    ).flatten();

    dartBoolean() => (
        string("true") | string("false")
    ).flatten();

    dartRawString() => (
        ref(dartRawStrTripleDouble)
        | ref(dartRawStrTripleSingle)
        | ref(dartRawStrSingle)
        | ref(dartRawStrDouble)
    );

    dartRawStrTripleDouble() => (
        char('r')
        & string('"""').untilSame()
    );

    dartRawStrTripleSingle() => (
        char('r')
        & string("'''").untilSame()

    );

    dartRawStrSingle() => (
        char('r')
        & string("'").untilSameInLine()
    );

    dartRawStrDouble() => (
        char('r')
        & string('"').untilSameInLine()
    );


    dartStrSingle() => (char("'") & (ref(dartExpr) | string(r"\'") | char("'").neg()).star() & char("'"));

    dartStrDouble() => char('"') & (ref(dartExpr) | string(r'\"') | char('"').neg()).star() & char('"');

    dartStrTripleSingle() => string("'''") & (ref(dartExpr) | string("'''").neg()).star() & string("'''");

    dartStrTripleDouble() => string('"""') & (ref(dartExpr) | string('"""').neg()).star() & string('"""');

    blockParenthesis() => char('(') & (
        ref(dartComments)
        | ref(dartString)
        | ref(blockParenthesis)
        | ref(blockBrace)
        | char(')').neg()
    ).star() & char(')') ;

    blockBrace() => (
        char('{')
        & NL
        & (
            ref(dartComments)
            | ref(dartString)
            | ref(blockParenthesis)
            | ref(blockBrace)
            | char('}').neg()
        ).star()
        & char('}')
    );

    dartComments() => (
        ref(dartMultiLineComment)
        | ref(dartSingleLineComment)
    );

    dartMultiLineComment() => (
        string("/*").untilString("*/")
    );

    dartSingleLineComment() => (
        string("//").untilChar("\n")
    );

    defFuncDirective() => (
        DEF
        & ref(name).trimInLine()
        & ref(paramListWithParenthesis).pick(1).trimInLine()
        & ref(blockTextWithRythmExpr)
    )
    .map((each) => new DefFuncDirective(each[1], each[2], each[3]));

    breakKeyword() => BREAK.map((_) => new Break());

    continueKeyword() => CONTINUE.map((_) => new Continue());

    verbatimDirective() => (
        VERBATIM &
        (
            (
                char('{').trimInLine()
                & char("\n")
                & (
                    string("\n}").neg().star()
                )
                & char('\n')
                & char("}")
                & NL
            ).permute([2, 3])
            | (
                char('{').trimLeftInLine()
                & anyIn('\n}').neg().star()
                & char('}')
                & NL.optional()
            ).pick(1)
        )
    ).pick(1)
    .map((each) => new VerbatimDirective(_flatToStr(each)));

    getDirective() => (
        GET.trimRightInLine()
        & (
            (
                char('(').trimInLine()
// TODO how to lazy?
                & anyIn('\n)').neg().star()
                & char(')')
            ).pick(1)
            | word().plus()
        )
    ).pick(1)
    .map((each) => new GetDirective(_flatToStr(each).trim()));

    setDirective() => (
        SET.trimInLine()
        & ref(namedArgItem)
        & NL
    ).pick(1)
    .map((each) => new SetDirective(each));

    includeDirective() => (
        INCLUDE
        & (
            (
                ref(relaxedName).trimInLine()
                & NL
            ).pick(0)
            |
            (
                char('(')
                & (anyIn('\n)').neg()).plus()
                & char(')')
            ).pick(1)
        )
    ).pick(1)
    .map((each) => new IncludeDirective(_flatToStr(each)));

    blockTextWithRythmExpr() => (
        char('{')
        & (
            whitespaceInLine().star()
            & char("\n")
        ).optional()
        & (
            ref(renderBody)
            | ref(forDirective)
            | ref(ifElseDirective)
            | ref(breakKeyword)
            | ref(continueKeyword)
            | ref(verbatimDirective)
            | ref(rythmExpr)
            | char('}').neg()
        ).star()
        & char('}').trim()
    ).pick(2)
    .map((each) => new RythmBlock(each == null ? [] : each));

    Document _createDocument(List list) {
        var doc = new Document(list);
        _fixString(doc);
        return doc;
    }

}

