part of rythm;


Parser _token(String str) {
	return string(str).trim().token();
}

whitespaceWithoutNL() => char('\n').neg().and().seq(whitespace());

RefParser ref(ToParser p) => new RefParser(p);

class RythmParser {

	final ARGS = _token("@args");

	final IMPORT = _token("@import");

	final INCLUDE = _token("@include");

	final IF = _token("@if");

	final ELSE = _token("@else");

	final BREAK = _token("@break");

	final CONTINUE = _token("@continue");

	final DEF = _token("@def");

	final EXTENDS = _token("@extends");

	final RENDER_BODY = _token("@renderBody");

	final GET = _token("@get");

	final SET = _token("@set");

	final FOR = _token("@for");

	final VAR = _token("var");

	final IN = _token("in");

	final AS = _token("as");

// @args String name, int age

	html() => any();

	name() => word().plus()
	.map((each) => new Name(each.join()));

	entryArgs() => (ARGS & (
		ref(paramListWithParenthesis).pick(1)
		| ref(paramList))
	).pick(1)
	.map((each) => new EntryArgs(each));

	paramList() => (
		ref(paramItem).separatedBy(char(','), includeSeparators:false)
	);

	paramItem() => (
		ref(name).trim()
		& ref(name).trim()
	).map((each) => new ArgItem(each[0], each[1]));

	paramListWithParenthesis() => char('(') & ref(paramList).optional() & char(')');

// @import "dart:xxx"

	importDirective() => (
		IMPORT
		& (char('"') & char('"').neg().star() & char('"')).trim()
		& (
			AS &
			ref(name)
		).optional()
	).pick(1)
	.map((each) => new Import(each[0], each[1]));

// @if(...) {} else if(...) {} else {}

	ifElseIfElse() => (
		ref(ifClause).separatedBy(ELSE.trim(), includeSeparators:false)
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
		& ref(name)
	);

// @aaa.bbb().ccc((r)=>r.xxx>1).ddd((x){return x>3;})

	invocationChain() => (
		ref(invocationItem).separatedBy(char('.'), includeSeparators:false)
	);

	invocationChainWithSpaces() => (
		ref(invocationItem).trim().separatedBy(char('.'), includeSeparators:false)
	);

	invocationItem() => (
		ref(name)
		& ref(blockParenthesis).pick(1).optional()
	)
	.map((each) => new Invocation(each[0], _flatToStr(each[1])));


// { ... }

	plainBlock() => char('{') & ref(plain) & char('}');


	plain() => (ref(blockBrace) | ref(html)).star();


	start() => ref(document).end();


	document() => (
		ref(importDirective)
		| ref(entryArgs)
		| ref(defFunc)
		| ref(ifElseIfElse)
		| ref(dartCode)
		| ref(dartExpr)
		| ref(rythmExpr)
		| ref(html)
	).star()
	.map((each) => _createDocument(each));

	dartCode() => (
		char('@')
		& ref(blockBrace).pick(1)
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
			) .pick(1)
		)
	).pick(1)
	.map((each) => new RythmExpr(each));

	dartExpr() => (
		char(r"$")
		& (
			ref(invocationChain)
			| (char('{') & ref(invocationChain) & char('}')).pick(1)
		)
	).pick(1)
	.map((each) => new DartExpr(each));

	dartString() => (
		ref(dartStrTripleDouble)
		| ref(dartStrTripleSingle)
		| ref(dartStrSingle)
		| ref(dartStrDouble)
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

	blockBrace() => char('{') & (
		ref(dartComments)
		| ref(dartString)
		| ref(blockParenthesis)
		| ref(blockBrace)
		| char('}').neg()
	).star() & char('}');

	dartComments() => (
		ref(dartMultiLineComment)
		| ref(dartSingleLineComment)
	);

	dartMultiLineComment() => (
		string("/*") & string("*/").neg().star() & string("*/")
	);

	dartSingleLineComment() => (
		string("//") & char("\n").neg().star() & char("\n")
	);

	defFunc() => (
		DEF
		& ref(name).trim()
		& ref(paramListWithParenthesis).pick(1).trim()
		& ref(blockTextWithRythmExpr).pick(1)
	)
	.map((each) => new DefFunc(each[1], each[2], each[3]));

	blockTextWithRythmExpr() => (
		char('{').trim()
		& ref(textWithRythmExpr)
		& char('}').trim()
	);

	textWithRythmExpr() => (
		ref(rythmExpr)
		| ref(html)
	).star();


	Document _createDocument(List list) {
		var doc = new Document(list);
		_fixString(doc);
		return doc;
	}

}

