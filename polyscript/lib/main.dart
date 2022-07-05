import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/editor_inherit.dart';
import 'package:polyscript/ui/editor/text_editor_widget.dart';
import 'ui/colors.dart';
import 'ui/styles.dart';

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
  final fieldController = TextEditingController(text: "user_228");
  final fileCodeController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: background,
        constraints: const BoxConstraints.expand(width: double.infinity),
        child: Column(
          children: [
            topBar,
            const Spacer(),
            newFileButton,
            const SizedBox(height: 12),
            connectToFileButton,
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget get topBar {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Row(
          children: [
            appTitle,
            const Spacer(),
            usernameField,
          ],
        ),
      ),
    );
  }

  Widget get appTitle {
    return const Text(
      "Polyscript",
      style: TextStyle(
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w900,
        color: text,
        fontSize: 20,
      ),
    );
  }

  Widget get usernameField {
    return Container(
      width: 196,
      height: 36,
      decoration: const BoxDecoration(color: highlight, borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Row(
        children: [
          const SizedBox(width: 36, height: 36, child: Icon(Icons.person, size: 20, color: disable)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: fieldController,
              decoration: null,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                color: text,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get newFileButton {
    return ElevatedButton(
      onPressed: () {
        late EditorModel editorModel;

        editorModel = EditorModel.createFile(
          fieldController.text,
          (error) => error == null ? openEditor(editorModel) : presentDialog("Ошибка", error),
        );
      },
      child: const Text(
        "Новый файл",
        style: textStyle,
      ),
      style: buttonStyle,
    );
  }

  Widget get connectToFileButton {
    return ElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Код файла", style: textStyle),
                content: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration:
                      const BoxDecoration(color: highlight, borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: TextField(
                    controller: fileCodeController,
                    decoration: null,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    style: plainButton,
                    onPressed: () {
                      late EditorModel model;
                      model = EditorModel.connectFile(
                        fieldController.text,
                        int.parse(fileCodeController.text),
                        (msg) =>
                            msg == null ? {Navigator.pop(context), openEditor(model)} : presentDialog("Ошибка", msg),
                      );
                    },
                    child: const Text("Присоединиться"),
                  ),
                ],
              );
            });
      },
      child: const Text(
        "Присоединиться",
        style: textStyle,
      ),
      style: buttonStyle,
    );
  }

  void presentDialog(title, message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
  }

  void openEditor(EditorModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditorInherit(
            editor: model,
            child: Container(
              constraints: const BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
              child: const TextEditorWidget(),
            ),
          );
        },
      ),
    );
  }
}
