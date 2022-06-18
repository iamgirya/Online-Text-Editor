import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:polyscript/ui/cursor_painter.dart';
import 'model/user.dart';
import 'ui/SelectText.dart';


 List<User> users = [];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
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

  @override
  void initState() {
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

  void onClick(TextPainter textPainter,TapDownDetails details) {
    setState(() {
      if (users.isNotEmpty) {
        users.removeLast();
      }

      var carretNumber = textPainter.getPositionForOffset(details.localPosition).offset;
      Offset carretPozition = textPainter.getOffsetForCaret(textPainter.getPositionForOffset(details.localPosition), Rect.zero);

      users.add( User(Point(carretPozition.dx, carretPozition.dy), "StarProximaa", Colors.teal));
      print("Selection: ${carretNumber}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 280,
      color: Colors.yellow,
      child: Stack(
          children: [
            SelectText(onClick: onClick),
            CustomPaint(
              painter: CursorPainter(users, scrollOffset: scrollController.hasClients ? scrollController.offset : 0))
          ],
        ),
    );
  }
}


