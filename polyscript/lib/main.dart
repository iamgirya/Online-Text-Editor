import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:polyscript/ui/cursor_painter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/user.dart';
import 'ui/SelectText.dart';
import 'ui/editor/text_editor.dart';

List<User> users = [];

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
  final fieldController = TextEditingController();
  final scrollController = ScrollController(initialScrollOffset: 0);
  late WebSocketChannel socket;
  @override
  void initState() {
    socket = WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:8081"));

    fieldController.addListener(() {
      onEditing();
    });
    scrollController.addListener(() {
      onEditing();
    });
    super.initState();
  }

  void onEditing() {
    setState(() {});
  }

  void onClick(TextPainter textPainter, TapDownDetails details) {
    setState(() {
      if (users.isNotEmpty) {
        users.removeLast();
      }

      var carretNumber = textPainter.getPositionForOffset(details.localPosition).offset;
      Offset carretPozition =
          textPainter.getOffsetForCaret(textPainter.getPositionForOffset(details.localPosition), Rect.zero);

      users.add(User(Point(carretPozition.dx, carretPozition.dy), "StarProximaa", Colors.teal));
      print("Selection: ${carretNumber}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
      child: TextEditor(),
    );
  }
}
