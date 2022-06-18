// Подключаем библиотеку для работы с WebSocket
const WebSocket = require('ws');

// Создаём подключение к WS
let wsServer = new WebSocket.Server({
    port: 8081
});

function generateFileCode() {
    for(var i = 0; ; i++) {
        if (files.find((file) => file.fileCode == i) == undefined) {
            return i;
        }
    }

    return -1;
}

class User {
    constructor(name, fileCode, socket) {
        this.name = name;
        this.fileCode = fileCode;
        this.socket = socket;
    }
}

class CloudFile {
    constructor(fileCode) {
        this.fileCode = fileCode;
        this.users = [];
    }
}

// Создаём массив для хранения всех подключенных пользователей
let users = []
let files = []
 
// Проверяем подключение
wsServer.on('connection', function (ws) {
    let user = new User("", -1, ws);
    users.push(user)
    console.log("connection!");

    ws.on('message', function (msg) {
        console.log("message! " + msg)

        let message = JSON.parse(msg);


        if (message.action == "login") {
        
            console.log("it action!")

            let unloginedUser = users.find((u) => u.socket == ws)
            if (unloginedUser != undefined) {
                unloginedUser.name = message.username;
                unloginedUser.fileCode = generateFileCode();

                let file = new CloudFile(unloginedUser.fileCode);
                file.users.push[unloginedUser];
                files.push(file);

                unloginedUser.socket.send(JSON.stringify({
                    'fileCode': unloginedUser.fileCode,
                    'result': 'ok',
                }));

                console.log("users list:")
                users.forEach ((user) => {
                    console.log(user.name);
                });
            }
        } else if (message.action == "connection") {
            let fileCode = message.fileCode;
            let username = message.username;
        }
    })
    // Делаем действие при выходе пользователя из чата
    ws.on('close', function () {
        console.log("closed(");
        let popUser = users.findIndex((u) => u.socket == ws);

        if (popUser != -1) {
            let usedFile = files.find((file) => file.fileCode == users[popUser].fileCode)

            if (usedFile != undefined) {
                usedFile.users = usedFile.users.filter((u) => u.socket != popUser[popUser].socket);
            }
        }

        users.splice(popUser, 1)
    })
})