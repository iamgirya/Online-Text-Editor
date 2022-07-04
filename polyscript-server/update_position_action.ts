import { EditorModel } from "./editor_model";
import { Point } from "./point";
import { Selection } from "./selection";

export class UpdatePositionAction {
    username: string;
    position: Point;

    execute(model: EditorModel) {
        var userIndex = model.users.findIndex((user) => user.username == this.username);

        if (userIndex != -1) {
            model.users[userIndex].cursorPosition = this.position;
            model.users[userIndex].selection = new Selection(this.position, this.position);
        }
    }

    constructor(username: string, position: Point) {
        this.username = username
        this.position = position
    }

    static fromJson(json: any) {
        return new UpdatePositionAction(json.username, new Point(json.position[0], json.position[1]))
    }

    toJson() {
        return JSON.stringify({
            "action": "update_position",
            "username": this.username,
            "position": [this.position.x, this.position.y]
        })
    }
}
