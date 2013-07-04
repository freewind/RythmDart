part of rythm;

class RythmParser {

    final PARAMS = string("@params").trimRightInLine();

    final IMPORT = string("@import").trimInLine();

    final INCLUDE = string("@include");

    final IF = string("@if").trimRightInLine();

    final ELSE = string("@else").trimInLine();

    final BREAK = string("@break");

    final CONTINUE = string("@continue");

    final DEF = string("@def").trimRightInLine();

    final EXTENDS = string("@extends").trimInLine();

    final RENDER_BODY = string("@renderBody");

    final GET = string("@get");

    final SET = string("@set");

    final FOR = string("@for");

    final VAR = string("var");

    final IN = string("in");

    final AS = string("as");

    final WITH_BODY = string("withBody");

    final NL = string("\n").optional("");

// @params String name, int age

    html() => any();

    name() => word().plus()
    .map((each) => new Name(each.join()));

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
        & char('"').untilSameInLine().trimInLine()
        & (
            AS &
            ref(name)
        ).optional()
    ).pick(1)
// FIXME
    .map((each) => new ImportDirective(each[0], each[1]));

// @if(...) {} else if(...) {} else {}

    ifElseIfElse() => (
        ref(ifClause).separatedBy(ELSE, includeSeparators:false)
        & (
            ELSE
            & ref(blockBrace).trim()
        ).optional()
    );

    ifClause() => (
        IF
        & ref(blockParenthesis).pick(1).trim()
        & ref(blockBrace).trim()
    );

    forDirective() => (
        FOR
        & char('(')
        & ref(forClause)
        & char(')')
        & ref(blockTextWithRythmExpr)
        & (
            ELSE
            & ref(blockTextWithRythmExpr)
        )
    );

    forClause() => (
        VAR
        & ref(name)
        & IN
        & ref(invocationChain)
    );

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
        ref(name)
        & char('=').trimInLine()
        & ref(simpleRythmExpr)
    ).map((each) {
        var value = each[2];
        value = value is List ? value : [value];
        return new NamedArg(each[0], value);
    }) ;

    renderBody() => (
        RENDER_BODY
        & (
            char('(')
            & ref(name).trim().separatedBy(char(','), includeSeparators:false)
            & char(')')
        ).pick(1).optional()
    ).pick(1).map((each) => new RenderBody(each));

    callFuncWithBody() => (
        char('@')
        & ref(name)
        & ref(blockParenthesis).pick(1)
        & WITH_BODY
        & (
            char('(')
            & ref(name).separatedBy(char(',').trim(), includeSeparators:false).optional([])
            & char(')')
        ).pick(1).optional()
        & ref(blockTextWithRythmExpr)
    ).map((each) => new CallFuncWithBodyDirective(each[1], _flatToStr(each[2]), each[4], each[5]));

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
        string("@*").until("*@")
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
        | ref(defFunc)
        | ref(renderBody)
        | ref(callFuncWithBody)
        | ref(ifElseIfElse)
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
        | ref(invocationChain)
        | ref(blockTextWithRythmExpr)
// | // TODO
    );

    dartString() => (
        ref(dartStrTripleDouble)
        | ref(dartStrTripleSingle)
        | ref(dartStrSingle)
        | ref(dartStrDouble)
        | ref(dartRawString)
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
        string("/*").until("*/")
    );

    dartSingleLineComment() => (
        string("//").until("\n")
    );

    defFunc() => (
        DEF
        & ref(name).trimInLine()
        & ref(paramListWithParenthesis).pick(1).trimInLine()
        & ref(blockTextWithRythmExpr)
    )
    .map((each) => new DefFuncDirective(each[1], each[2], each[3]));

    blockTextWithRythmExpr() => (
        char('{').trimInLine()
        & NL
        & (
            ref(renderBody)
            | ref(rythmExpr)
            | char('}').neg()
        ).star()
        & char('}').trim()
    ).pick(2);

    Document _createDocument(List list) {
        var doc = new Document(list);
        _fixString(doc);
        return doc;
    }

}

