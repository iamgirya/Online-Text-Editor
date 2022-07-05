import { EditorModel } from "./editor_model";
import { Point } from "./point";
import { Selection } from "./selection";

export class ReplaceTextAction {

    username: string
    insertingText: string[]
    model: EditorModel
    selectedRange: Selection

    constructor(username: string, insertingText: string[]) {
        this.username = username
        this.insertingText = insertingText
    }

    static fromJson(json: any) { 
        return new ReplaceTextAction(json["username"],json["text"].split("\n"));
    }

    execute(model: EditorModel) {
        this.model = model;
        this.selectedRange = model.users.find((user) => user.username == this.username).selection.copy();

        this.deleteSelectedText();
        this.updateUsersAfterDeleting();
        this.insertText();
        this.updateUsersAfterInserting();
    }

    deleteSelectedText() {
        var prefix = this.model.file.lines[this.selectedRange.start.y].substring(0, this.selectedRange.start.x);
        var suffix = this.model.file.lines[this.selectedRange.end.y].substring(this.selectedRange.end.x);

        if (suffix == undefined) {
            suffix = ""
        }

        this.model.file.lines.splice(this.selectedRange.start.y, this.selectedRange.end.y - this.selectedRange.start.y + 1);

        this.model.file.lines.splice(this.selectedRange.start.y,0, prefix + suffix);
    }

    updateUsersAfterDeleting() {
        this.model.users.forEach(user => {
            user.cursorPosition = this.pointAfterDeleting(user.cursorPosition);
            user.selection.start = this.pointAfterDeleting(user.selection.start);
            user.selection.end = this.pointAfterDeleting(user.selection.end);
        });
    }

    pointAfterDeleting(point: Point) {
        if (this.selectedRange.constaint(point)) {
            return this.selectedRange.start;
        } else if (point.y == this.selectedRange.end.y && point.x >= this.selectedRange.end.x) {
            return new Point(this.selectedRange.start.x + point.x - this.selectedRange.end.x, this.selectedRange.start.y);
        } else if (point.y > this.selectedRange.end.y) {
            return new Point(point.x, this.selectedRange.start.y + point.y - this.selectedRange.end.y);
        } else {
            return point;
        }
    }

    insertText() {
        var prefix = this.model.file.lines[this.selectedRange.start.y].substring(0, this.selectedRange.start.x);
        var suffix = this.model.file.lines[this.selectedRange.start.y].substring(this.selectedRange.start.x);

        if (this.insertingText.length == 1) {
            this.model.file.lines[this.selectedRange.start.y] = prefix + this.insertingText[0] + suffix;
        } else {
            this.model.file.lines[this.selectedRange.start.y] = prefix + this.insertingText[0];

            for (var i = 1; i < this.insertingText.length - 1; i++) {
                this.model.file.lines.splice(this.selectedRange.start.y + i - 1, 0, this.insertingText[i]);
            }

            this.model.file.lines
                .splice(
                    this.selectedRange.start.y + this.insertingText.length - 1,
                    0, 
                    this.insertingText[this.insertingText.length - 1] + suffix
                );
        }
    }

    updateUsersAfterInserting() {
        this.model.users.forEach(user => {
            user.cursorPosition = this.pointAfterInserting(user.cursorPosition);
            user.selection.start = this.pointAfterInserting(user.selection.start);
            user.selection.end = this.pointAfterInserting(user.selection.end);
        })
    }

    pointAfterInserting(point: Point) {
        if (point.y == this.selectedRange.start.y && point.x >= this.selectedRange.start.x) {
            if (this.insertingText.length == 1) {
                return new Point(this.insertingText[this.insertingText.length - 1].length + point.x, point.y + this.insertingText.length - 1);
            } else {
                return new Point(this.insertingText[this.insertingText.length - 1].length + point.x - this.selectedRange.start.x, point.y + this.insertingText.length - 1);
            }
        } else if (point.y > this.selectedRange.start.y) {
            return new Point(point.x, point.y + this.insertingText.length - 1);
        } else {
            return point;
        }
    }

    toJson() {
        return JSON.stringify(
            {
                "action": "replace_text",
                "username": this.username,
                "text": this.insertingText
            },
        );
    }
}