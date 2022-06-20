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

    users = [];
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
    print(message);
    if (json["action"] == "new_user") {
      var user = jsonDecode(json["user"]);

      var username = user["user_name"].toString();

      if (username != localUser.name) {
        var point = user["position"];
        users.add(User(Point(point[0], point[1]), username, Colors.indigo));
        notifyListeners();
      }
    } else if (json["action"] == "user_update_position") {
      var username = json["username"].toString();
      var userIndex = users.indexWhere((user) => user.name == username);
      print(userIndex);

      if (userIndex != -1) {
        print("update position!");
        var point = json["newPosition"];
        users[userIndex].cursorPosition = Point(point[0], point[1]);
        notifyListeners();
      }
    } else if (json["action"] == "user_exit") {
      var username = json["username"].toString();
      users.removeWhere((user) => user.name == username);
      notifyListeners();
    } else if (json["action"] == "send_file_state") {
      var jsonUsers = json["users"];

      for (var user in jsonUsers) {
        var userJson = jsonDecode(user);
        var point = userJson["position"];

        users.add(User(Point(point[0], point[1]), userJson["username"], Colors.indigo));
      }

      notifyListeners();
    }
  }
}
