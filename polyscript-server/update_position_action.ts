import { EditorModel } from "./editor_model";
import { Point } from "./point";
import { Selection } from "./selection";

export class UpdatePositionAction {
    username: String;
    position: Point;
  
    constructor(username: String, position: Point) {
        this.username = username
        this.position = position
    }
  
    static fromJson(json: any) {
        return new UpdatePositionAction(json.username, new Point(json.position[0], json.position[1]));
    }
  
    execute(model: EditorModel) {
      var movedUser = model.users.find((user) => user.username == this.username)
  
      movedUser.cursorPosition = this.position
      movedUser.selection = new Selection(this.position, this.position)
    }
  
    toJson() {
        return JSON.stringify(
            {
                "action": "update_position",
                "username": this.username,
                "position": [this.position.x, this.position.y]
            },
        );
    }
}