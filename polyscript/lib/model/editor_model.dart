import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/actions/replace_text_action.dart';
import 'package:polyscript/model/file_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'user_model.dart';

class EditorModel extends ChangeNotifier {
  late FileModel file;
  late List<User> users;
  late String localUserName;
  late WebSocketChannel socket;
  User get localUser => users.firstWhere((element) => element.name == localUserName);

  void updateLocalUser({Point<int>? newPosition, Selection? newSelection}) {
    if (newPosition != null || newSelection != null) {
      if (newPosition != null) {
        localUser.cursorPosition = newPosition;
        localUser.selection = Selection(newPosition, newPosition);
      }

      if (newSelection != null) {
        localUser.selection = newSelection;
      }

      notifyListeners();

      socket.sink.add(
        jsonEncode(
          {
            "action": "position_update",
            "username": localUser.name,
            "newPosition": [localUser.cursorPosition.x, localUser.cursorPosition.y],
          },
        ),
      );
    }
  }

  void makeNewLine(int lineIndex, String startText) {
    file.lines.insert(lineIndex, startText);

    notifyListeners();
  }

  void deleteLine(int lineIndex) {
    file.lines.removeAt(lineIndex);

    notifyListeners();
  }

  void deleteLines(int startLineIndex, int endLineIndex) {
    file.lines.removeRange(startLineIndex, endLineIndex);

    notifyListeners();
  }

  void sendJSON(dynamic json) {
    socket.sink.add(json);
  }

  EditorModel.createFile(this.localUserName) {
    print("new connection!");
    users = [
      User(
        const Point(0, 0),
        localUserName,
        Colors.indigo,
        Selection(
          const Point(0, 0),
          const Point(0, 0),
        ),
      )
    ];

    //socket = WebSocketChannel.connect(Uri.parse("ws://178.20.41.205:8081"));
    socket = WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:8081"));

    socket.stream.listen(listenServer);

    socket.sink.add(
      jsonEncode(
        {
          "action": "login",
          "username": localUser.name,
        },
      ),
    );

    file = FileModel(
      "test",
      -1,
      [
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
        "very long line very long line very long line",
      ],
    );
  }

  void listenServer(message) {
    var json = jsonDecode(message);

    switch (json["action"]) {
      case "new_user":
        var user = jsonDecode(json["user"]);
        var username = user["user_name"].toString();

        if (username != localUser.name) {
          var point = user["position"];
          users.add(
            User(
              Point(point[0], point[1]),
              username,
              Colors.indigo,
              Selection(
                const Point(0, 0),
                const Point(0, 0),
              ),
            ),
          );
          notifyListeners();
        }
        break;

      case "user_update_position":
        var username = json["username"].toString();
        var userIndex = users.indexWhere((user) => user.name == username);

        if (userIndex != -1) {
          var point = json["newPosition"];
          users[userIndex].cursorPosition = Point(point[0], point[1]);
          notifyListeners();
        }
        break;

      case "user_exit":
        var username = json["username"].toString();
        users.removeWhere((user) => user.name == username);
        notifyListeners();
        break;

      case "send_file_state":
        var jsonUsers = json["users"];

        for (var user in jsonUsers) {
          var userJson = jsonDecode(user);
          var point = userJson["position"];

          users.add(User(
            Point(point[0], point[1]),
            userJson["username"],
            Colors.indigo,
            Selection(
              const Point(0, 0),
              const Point(0, 0),
            ),
          ));
        }

        notifyListeners();
        break;

      case "replace_text":
        var action = ReplaceTextAction.fromJson(json);
        action.execute(this);
        notifyListeners();
        break;
    }
  }
}
