import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/model/file_model.dart';
import 'package:polyscript/ui/editor/line_widget.dart';
import 'package:provider/provider.dart';

import 'editor_inherit.dart';

class TextEditorWidget extends StatefulWidget {
  const TextEditorWidget({Key? key}) : super(key: key);

  @override
  State<TextEditorWidget> createState() => _TextEditorWidgetState();
}

class _TextEditorWidgetState extends State<TextEditorWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    EditorModel editor = EditorInherit.of(context).editor;

    return LayoutBuilder(
      builder: ((context, constraints) {
        return ListView.builder(
          itemCount: editor.file.lines.length,
          itemBuilder: ((context, index) {
            return ChangeNotifierProvider.value(
              value: editor,
              child: LineWidget(
                text: editor.file.lines[index],
                index: index,
                lineWidth: constraints.maxWidth,
              ),
            );
          }),
          controller: scrollController,
        );
      }),
    );
  }
}
