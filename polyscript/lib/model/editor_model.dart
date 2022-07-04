import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/actions/replace_text_action.dart';
import 'package:polyscript/model/actions/update_position_action.dart';
import 'package:polyscript/model/file_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'action.dart';
import 'user_model.dart';

class EditorModel extends ChangeNotifier {
  late FileModel file;
  late List<User> users;
  late String localUserName;
  late WebSocketChannel socket;
  late Function onUpdate;
  Queue<EditorAction> requestQueue = Queue();
  static const int queueMaxCount = 1;
  User get localUser => users.firstWhere((element) => element.name == localUserName);

  void updateLocalUser({Point<int>? newPosition, Selection? newSelection}) {
    if (newPosition != null || newSelection != null) {

      if (newSelection != null) {
        localUser.selection = newSelection;
      }

      notifyListeners();
    }
  }

  String getSelectedText() {
    String text = "";
    Selection selection = localUser.selection.readyToWork;
    if (selection.start.y == selection.end.y) {
      text = file.lines[selection.start.y].first.substring(selection.start.x, selection.end.x);
    } else {
      text = file.lines[selection.start.y].first.substring(selection.start.x);
      for (int i = selection.start.y+1; i < selection.end.y; i++) {
        text += "\n" + file.lines[i].first;
      }
      text += file.lines[selection.end.y].first.substring(0, selection.end.x);
    }
    return text;
  }

  void sendJSON(EditorAction actionToSend) {
    String json = actionToSend.toJson();

    if (requestQueue.length < queueMaxCount && !(requestQueue.isNotEmpty && (actionToSend is UpdatePositionAction) && requestQueue.last == actionToSend)) {
      requestQueue.add(actionToSend);

      socket.sink.add(json);
    }
    print(requestQueue.length);
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
        "0very long line very long line very long line",
        "1very long line very long line very long line",
        "2very long line very long line very long line",
        "3very long line very long line very long line",
        "4very long line very long line very long line",
        "5very long line very long line very long line",
        "6very long line very long line very long line",
        "7very long line very long line very long line",
        "8very long line very long line very long line",
        "9very long line very long line very long line",
        "10very long line very long line very long line",
        "11very long line very long line very long line",
        "12very long line very long line very long line",
        "13very long line very long line very long line",
        "14very long line very long line very long line",
        "15very long line very long line very long line",
        "16very long line very long line very long line",
        "17very long line very long line very long line",
        "18very long line very long line very long line",
        "19very long line very long line very long line",
        "20very long line very long line very long line",
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
    EditorAction? action;

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

      case "position_update":
        action = UpdatePositionAction.fromJson(json);
        action.execute(this);
        notifyListeners();
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
        action = ReplaceTextAction.fromJson(json);
        action.execute(this);
        notifyListeners();
        break;
    }

    onUpdate();

    if (requestQueue.isNotEmpty && action != null
      && (action == requestQueue.first)
    
    ) {
      requestQueue.removeFirst();
    }
  }
}
