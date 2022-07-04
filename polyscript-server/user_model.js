"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const selection_1 = require("./selection");
const point_1 = require("./point");
class User {
    constructor(name, socket, fileCode) {
        this.username = name;
        this.cursorPosition = new point_1.Point(0, 0);
        this.selection = new selection_1.Selection(this.cursorPosition, this.cursorPosition);
        this.socket = socket;
        this.fileCode = fileCode;
    }
    toJson() {
        return JSON.stringify({
            "username": this.username,
            "position": [this.cursorPosition.x, this.cursorPosition.y],
            "selection": [this.selection.start.x, this.selection.start.y, this.selection.end.x, this.selection.end.y],
        });
    }
}
exports.User = User;
