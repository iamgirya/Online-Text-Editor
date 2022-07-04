"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdatePositionAction = void 0;
const point_1 = require("./point");
const selection_1 = require("./selection");
class UpdatePositionAction {
    constructor(username, position) {
        this.username = username;
        this.position = position;
    }
    execute(model) {
        var userIndex = model.users.findIndex((user) => user.username == this.username);
        if (userIndex != -1) {
            model.users[userIndex].cursorPosition = this.position;
            model.users[userIndex].selection = new selection_1.Selection(this.position, this.position);
        }
    }
    static fromJson(json) {
        return new UpdatePositionAction(json.username, new point_1.Point(json.position[0], json.position[1]));
    }
    toJson() {
        return JSON.stringify({
            "action": "update_position",
            "username": this.username,
            "position": [this.position.x, this.position.y]
        });
    }
}
exports.UpdatePositionAction = UpdatePositionAction;
