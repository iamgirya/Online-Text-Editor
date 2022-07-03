import 'package:flutter/widgets.dart';

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);
}

class FileModel {
  String name;
  int fileCode;
  late List<Pair<String, GlobalKey>> lines;
  FileModel(this.name, this.fileCode, List<String> l) {
    lines = [];
    for (var x in l) {
      lines.add(Pair(x, GlobalKey()));
    }
  }
}
