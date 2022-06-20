import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';

class EditorInherit extends InheritedWidget {
  const EditorInherit({
    Key? key,
    required Widget child,
    required this.editor,
  }) : super(key: key, child: child);

  final EditorModel editor;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static EditorInherit of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EditorInherit>()!;
  }
}
