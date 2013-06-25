part of rythm;

class RythmGrammar extends CompositeParser {

  void initialize() {

    def("start", (ref("args") | ref("invocation") | ref("html")).star().end());

// [:@args String who, int age:]
    def("args", string('@args') & ref("param_list_def"));
// [:String:], or [:name:]
    def("name", word().plus().flatten().trim());
// @who
    def("invocation", char('@') & ref("invocation.item").separatedBy(char('.'), includeSeparators: false));
    def("invocation.item", ref("name") & ref("fun_params").optional());
// ("aaa","bbb")
    def("fun_params", char('(') & ref("param_list_def").optional() & char(')'));
// String name
    def("param_def", ref("name") & ref("name"));
// String name, String message
    def("param_list_def", ref("param_def").separatedBy(char(','), includeSeparators:false));
// any other char
    def("html", any());
  }

}
