import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:polyscript/model/action_names.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/editor_inherit.dart';
import 'package:polyscript/ui/editor/text_editor_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/user_model.dart';
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
  late WebSocketChannel userSocket;

  void onServerError(stack) {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Ошибка"),
            content: Text("Не удалось подключиться к серверу."),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: background,
        constraints: const BoxConstraints.expand(width: double.infinity),
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  children: [
                    const Text(
                      "Polyscript",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w900,
                        color: text,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 196,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: highlight,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: disable,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
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
                    )
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                late EditorModel editorModel;
                editorModel = EditorModel.createFile(
                  fieldController.text,
                  (error) {
                    if (error == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EditorInherit(
                              editor: editorModel,
                              child: Container(
                                constraints:
                                    const BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
                                child: const TextEditorWidget(),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Ошибка"),
                              content: Text(error),
                            );
                          });
                    }
                  },
                );
              },
              child: const Text(
                "Новый файл",
                style: textStyle,
              ),
              style: buttonStyle,
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Код файла",
                          style: textStyle,
                        ),
                        content: Container(
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: highlight, borderRadius: BorderRadius.all(Radius.circular(12))),
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
                              model = EditorModel.connectFile(fieldController.text, int.parse(fileCodeController.text),
                                  (msg) {
                                if (msg == null) {
                                  Navigator.pop(context);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EditorInherit(
                                          editor: model,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                minWidth: double.infinity, minHeight: double.infinity),
                                            child: const TextEditorWidget(),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  print(msg);
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Ошибка"),
                                          content: Text(msg),
                                        );
                                      });
                                }
                              });
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
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
