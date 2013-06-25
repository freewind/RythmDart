part of rythm;

class RythmGrammar extends CompositeParser {

  void initialize() {

    def("start", ref("document").end());

    def("document", (ref("args") | ref("code") | ref("html")).star());
// @args String name, int age
    def("args", (string('@args') & ref("args_list")).pick(1));
    def("args_list", ref("arg_item").separatedBy(char(','), includeSeparators:false));
    def("arg_item", ref("name") & ref("name"));

// @aaa.bbb().ccc((r)=>r.xxx>1).ddd((x){return x>3;})
    def("invocation_chain", ref("invocation_item").separatedBy(char('.'), includeSeparators:false));
    def("invocation_item", ref("name") & ref("block_parenthesis").optional());

// { ... }
    def("plain_block", char('{') & ref("plain") & char('}'));
    def("plain", (ref("block_brace") | ref("html")).star());

    def("fun_params", char('(') & ref("args_list").optional() & char(')'));
    def("name", word().plus().flatten().trim());
    def("html", any());

// @{ ... }
    def("code", (char("@") & ( ref("invocation_chain") | ref("block_brace")).flatten()).pick(1));
    def("dart_instr_expr", char(r'$') & ref("block_brace"));
    def("dart_str_single", char("'") & (ref("dart_instr_expr") | string(r"\'") | char("'").neg()).star() & char("'"));
    def("dart_str_double", char('"') & (ref("dart_instr_expr") | string(r'\"') | char('"').neg()).star() & char('"'));
    def("dart_str_triple_single", string("'''") & (ref("code") | string("'''").neg()).star() & string("'''"));
    def("dart_str_triple_double", string('"""') & (ref("code") | string('"""').neg()).star() & string('"""'));
    def("block_parenthesis", char('(') & (
        ref("dart_str_triple_single")
        | ref("dart_str_triple_double")
        | ref("dart_str_single")
        | ref("dart_str_double")
        | ref("block_parenthesis")
        | ref("block_brace")
        | char(')').neg().flatten()
    ).star() & char(')'));
    def("block_brace", char('{') & (
        ref("dart_str_triple_single")
        | ref("dart_str_triple_double")
        | ref("dart_str_single")
        | ref("dart_str_double")
        | ref("block_parenthesis")
        | ref("block_brace")
        | char('}').neg().flatten()
    ).star() & char('}'));
  }

}
