import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/file_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'user_model.dart';

class EditorModel extends ChangeNotifier {
  late FileModel file;
  late List<User> users;
  late WebSocketChannel socket;
  User localUser;

  void updateLocalUser({Point<int>? newPosition, Selection? newSelection}) {
    if (newPosition != null || newSelection != null) {
      if (newPosition != null) {
        localUser.cursorPosition = newPosition;
      }
      if (newSelection != null) {
        localUser.selection = newSelection;
      }
      notifyListeners();
    }
  }

  EditorModel.createFile(this.localUser) {
    socket = WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:8081"));
    socket.sink.add(
      jsonEncode(
        {
          "action": "login",
          "username": localUser.name,
        },
      ),
    );
    socket.stream.listen(listenServer);

    users = [
      User(const Point(2, 0), "Star Proxima", Colors.indigo),
      User(const Point(4, 1), "IAmGirya", Colors.pink),
      User(const Point(50, 2), "JakeApps", Colors.black),
      User(const Point(3, 2), "Flexer", Colors.teal),
      User(const Point(20, 5), "Cucumber228aye4", Colors.orange),
    ];
    file = FileModel(
      "test",
      -1,
      [
        "test",
        "flexing",
        "very long line very long line very long line very long line very long line",
        "flexing",
        "very long line very long line very long line very long line very long line",
        "very long line very long line very long line very long line very long line",
        "test",
        "test",
        "test",
      ],
    );
  }

  void listenServer(message) {
    var json = jsonDecode(message);
  }
}
