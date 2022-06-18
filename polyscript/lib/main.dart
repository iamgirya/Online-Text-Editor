import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:polyscript/ui/cursor_painter.dart';

import 'model/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainWidget(),
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  var users = [
    User(const Point(100, 36), "Delta Null", Colors.indigo),
    User(const Point(150, 76), "IAmGirya", Colors.black),
    User(const Point(60, 156), "StarProxima", Colors.teal)
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16),
            child: TextField(
              selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
              maxLines: null,
              decoration: const InputDecoration(contentPadding: EdgeInsets.all(0), isCollapsed: true),
              controller: fieldController,
              scrollController: scrollController,
              style: const TextStyle(
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 16,
                height: 1.25,
              ),
            ),
          ),
          for (int i = 0; i < users.length; i++)
            CustomPaint(
              painter: CursorPainter(users, scrollOffset: scrollController.hasClients ? scrollController.offset : 0),
            )
        ],
      ),
    );
  }
}
