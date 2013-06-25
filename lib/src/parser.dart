part of rythm;

class RythmParser extends RythmGrammar {

  void initialize() {
    super.initialize();
    action("document", (each) => _createDocument(each));
    action("args", (each) {
      var args = new Args();
      for (var typeName in each) {
        args.add(typeName[0], typeName[1]);
      }
      return args;
    });
    action("code", (each) => new Code(each)) ;
//    action("html", (each) => ":html:${each}") ;
  }

  Document _createDocument(List list) {
    // important, to make code simple, or it will lost ending string
    list.add(new End());

    List<Node> nodes = [];
    StringBuffer sb = null;
    for (final item in list) {
      print("${item.runtimeType.toString()}: $item");
      if (item is String) {
        if (sb == null) {
          sb = new StringBuffer(item);
        } else {
          sb.write(item);
        }
      } else {
        if (sb != null) {
          nodes.add(new Plain(sb.toString()));
          sb = null;
        }
        nodes.add(item);
      }
    }
    return new Document(nodes);
  }
}
