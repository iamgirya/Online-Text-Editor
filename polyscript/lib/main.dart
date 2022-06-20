import 'dart:math';
import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/editor_inherit.dart';
import 'package:polyscript/ui/editor/text_editor_widget.dart';
import 'model/user_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PolyScript',
      home: Scaffold(
        body: Center(
          child: MainWidget(),
        ),
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final EditorModel editor = EditorModel.createFile(
    User(const Point(0, 2), "Delta Null", Colors.red),
  );

  @override
  Widget build(BuildContext context) {
    return EditorInherit(
      editor: editor,
      child: Container(
        constraints: const BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
        child: const TextEditorWidget(),
      ),
    );
  }
}
