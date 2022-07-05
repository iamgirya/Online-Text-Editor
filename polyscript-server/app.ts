// Подключаем библиотеку для работы с WebSocket

import { WebSocket } from "ws"
import { ClearTextAction } from "./clear_text_action";
import { EditorModel } from "./editor_model";
import { FileModel } from "./file_model";
import { ReplaceTextAction } from "./replace_text_action";
import { UpdatePositionAction } from "./update_position_action";
import { User } from "./user_model";

// Создаём подключение к WS
let wsServer = new WebSocket.Server({
    port: 8081
});



let editors: EditorModel[] = []
let users: User[] = []

function generateFileCode() {
    for(var i = 0; ; i++) {
        if (editors.find((editor) => editor.file.code == i) == undefined) {
            return i
        }
    }
}

wsServer.on('connection', function (ws) {
    ws.on('message', function (msg: string) {
        console.log("message! " + msg)

        var message = JSON.parse(msg)

        switch (message.action) {
            case "create_file":
                var file = new FileModel("file name", generateFileCode(), [""]);
                var user = new User(message.username, ws, file.code);
                var editor = new EditorModel(file);
                editor.users.push(user);
                editors.push(editor)
                
                console.log(editors);

                user.socket.send(
                    JSON.stringify({
                        "action": "create_file",
                        "file_code": file.code,
                    })
                )

                users.push(user)
                break;

            case "connect_to_file":
                var connectionEditor = editors.find((editor) => editor.file.code == message.file_code)
                if(connectionEditor != undefined) {
                    if(connectionEditor.users.find((user) => user.username == message.username) == undefined) {
                        var newUser = new User(message.username, ws, message.file_code);
                        newUser.socket.send(
                            JSON.stringify({
                                "action": "update_file_state",
                                "users": connectionEditor.users.map((user) => user.toJson()),
                                "file": connectionEditor.file.lines,
                            })
                        )
                        
                        for(var i = 0; i < connectionEditor.users.length; i++) {
                            connectionEditor.users[i].socket.send(
                                JSON.stringify({
                                    "action": "user_connect",
                                    "username": newUser.username
                                })
                            )
                        }

                        connectionEditor.users.push(newUser)
                        users.push(newUser)
                    } else {
                        ws.send(
                            JSON.stringify({
                                "action": "error",
                                "error_message": "Пользователь с таким именем уже подключен к файлу.",
                            })
                        )
                    }
                } else {
                    ws.send(
                        JSON.stringify({
                            "action": "error",
                            "error_message": "Файла с таким кодом не существует.",
                        })
                    )
                }
                break;
        
            case "replace_text":
                var actionUser = users.find((user) => user.username == message.username)!
                var actionEditor = editors.find((editor) => editor.file.code == actionUser.fileCode)!
                var action = ReplaceTextAction.fromJson(message)
                
                console.log(action)
                console.log(actionEditor.file.lines);

                action.execute(actionEditor)

                for(var i = 0; i < actionEditor.users.length; i++) {
                    var user = actionEditor.users[i];
                    user.socket.send(JSON.stringify({
                        "action": message.action,
                        "username": message.username,
                        "text": message.text
                    }))
                }
                
                break;

            case "clear_text":
                var actionUser = users.find((user) => user.username == message.username)!
                var actionEditor = editors.find((editor) => editor.file.code == actionUser.fileCode)!
                var clearAction = ClearTextAction.fromJson(message)
                
                console.log(clearAction)
                console.log(actionEditor.file.lines)

                clearAction.execute(actionEditor)

                for(var i = 0; i < actionEditor.users.length; i++) {
                    var user = actionEditor.users[i];
                    user.socket.send(JSON.stringify({
                        "action": message.action,
                        "username": message.username
                    }))
                }
                
                break;

            case "update_position":
                var positionAction = UpdatePositionAction.fromJson(message)
                var actionUser = users.find((user) => user.username == message.username)!
                var actionEditor = editors.find((editor) => editor.file.code == actionUser.fileCode)!

                positionAction.execute(actionEditor);

                for(var i = 0; i < actionEditor.users.length; i++) {
                    actionEditor.users[i].socket.send(positionAction.toJson())
                }
                break;
        }
    })
    
    // действие при выходе пользователя из чата
    ws.on('close', function () {
        let closedUser = users.find((user) => user.socket == ws)!

        console.log(users.filter((user) => user.socket == ws));
        if (closedUser == null) return;
        console.log("exit: " + closedUser.username)
        let editor = editors.find((editor) => editor.file.code == closedUser.fileCode)!;
        for(var i = 0; i < editor.users.length; i++) {
            editor.users[i].socket.send(
                JSON.stringify({
                    "action": "user_disconnect",
                    "username": closedUser.username,
                })
            )
        }

        let index = users.indexOf(closedUser);
        users.splice(index, 1);

        let index2 = editor.users.indexOf(closedUser);
        editor.users.splice(index2, 1);

        if (editor.users.length == 0) {
            let editorIndex = editors.indexOf(editor);
            editors.splice(editorIndex,1);
        }

        console.log("users:")
        console.log(users.map((user) => user.username));

        console.log("files:")
        console.log(editors.map((editor) => editor.file.code));
    })
})
