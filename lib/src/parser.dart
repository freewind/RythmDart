part of rythm;

class RythmGrammar extends CompositeParser {

  void initialize() {

    def("start", ref("args"));

// @args String who
    def("args", string('@args') & (ref("arg_type") & ref("arg_value")).separatedBy(char(',').trim(), includeSeparators:false));
// String
    def("arg_type", word().plus().flatten().trim());
// name
    def("arg_value", word().plus().flatten().trim());
  }

}
