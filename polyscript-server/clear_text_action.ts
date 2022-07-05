import { EditorModel } from "./editor_model";
import { ReplaceTextAction } from "./replace_text_action";
import { Selection } from "./selection";
import { Point } from "./point";

export class ClearTextAction extends ReplaceTextAction {  
    constructor(username) {
        super(username, [""])
    }
  
    static fromJson(json: any) {
      return new ClearTextAction(json["username"]);
    }
    
    execute(model: EditorModel) {
      this.model = model;
      this.selectedRange = this.initSelectionForDeletingRange(model);
  
      this.deleteSelectedText();
      this.updateUsersAfterDeleting();
      this.insertText();
      this.updateUsersAfterInserting();
    }
  
    initSelectionForDeletingRange(model: EditorModel) {
      var userSelection = model.users.find((user) => user.username == this.username).selection.copy();
  
      console.log(userSelection);

      if (userSelection.isEmpty) {
        if (userSelection.start.x == 0 && userSelection.start.y != 0) {
          return new Selection(
            userSelection.start.add(new Point(model.file.lines[userSelection.start.y - 1].length, -1)),
            userSelection.start,
          );
        } else if (userSelection.start.x != 0) {
          return new Selection(
            userSelection.start.add(new Point(-1, 0)),
            userSelection.start,
          );
        } else {
          return userSelection;
        }
      } else {
        return userSelection;
      }
    }
  
    
    toJson() {
      return JSON.stringify({"action": "clear_text", "username": this.username});
    }
  }
  