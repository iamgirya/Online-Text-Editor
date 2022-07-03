// Подключаем библиотеку для работы с WebSocket
const WebSocket = require('ws');

// Создаём подключение к WS
let wsServer = new WebSocket.Server({
    port: 8081
});

function generateFileCode() {
    // for(var i = 0; ; i++) {
    //     if (files.find((file) => file.fileCode == i) == undefined) {
    //         return i
    //     }
    // }

    return -1;
}

class User {
    constructor(name, fileCode, socket) {
        this.name = name
        this.fileCode = fileCode
        this.socket = socket
        this.position = [-1,-1]
    }
}

function userToJson(user) {
    return JSON.stringify({
        "username" : user.name,
        "position" : user.position
    }).toString()
    //"{'username':" + user.name + ", position: " + user.position + "}"
  }

class CloudFile {
    constructor(fileCode) {
        this.fileCode = fileCode
        this.users = []
        this.lines = []
    }

    addNewUser(newUser) {
        console.log(this.users.map(userToJson))
        newUser.socket.send(
            JSON.stringify({
                "action": "send_file_state",
                "users": this.users.map(userToJson),
            })
        )

        this.users.push(newUser)
        this.users.forEach((user) => {
            user.socket.send(
                JSON.stringify({
                    'action': 'new_user',
                    'user': JSON.stringify({
                        'user_name': newUser.name,
                        'position': newUser.position,
                    })
                })
            )
        })
    }

    removeUser(removedUser) {
        this.users.pop(removedUser)
        console.log(removedUser.name)
        this.users.forEach((user) => {
            user.socket.send(
                JSON.stringify({
                    'action': 'user_exit',
                    'username': removedUser.name,
                })
            )
        })
    }
}

// Создаём массив для хранения всех подключенных пользователей
//let users = []
let file = new CloudFile()

function printUsers() {
    console.log("users list:")
    file.users.forEach ((user) => {
        console.log(user.name);
    });
}
 
// Проверяем подключение
wsServer.on('connection', function (ws) {
    let user = new User("", -1, ws);
    console.log("connection!");

    ws.on('message', function (msg) {
        console.log("message! " + msg)

        let message = JSON.parse(msg);

        if (message.action == "login") {
        
            console.log("it action!")

        user.name = message.username
        user.fileCode = generateFileCode()
        file.addNewUser(user)
        printUsers()

        } else if (message.action == "connection") {
            let fileCode = message.fileCode;
            let username = message.username;
        } else if (message.action == "replace_text") {
            file.users.forEach((user) => {
                user.socket.send(
                    JSON.stringify({
                        "action": message.action,
                        "username": message.username,
                        "selection": message.selection,
                        "text": message.text
                    })
                )
            })
        } else if (message.action == "position_update") {
            file.users.forEach((user) => {
                user.socket.send(
                    JSON.stringify({
                        "action": message.action,
                        "username": message.username,
                        "position": message.position
                    })
                )
            })
        }
    })
    
    // Делаем действие при выходе пользователя из чата
    ws.on('close', function () {
        console.log("closed(");
        let popUser = file.users.find((u) => u.socket == ws);
        file.removeUser(popUser)
        printUsers()
    })
})