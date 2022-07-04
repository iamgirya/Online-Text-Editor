"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReplaceTextAction = void 0;
const point_1 = require("./point");
const selection_1 = require("./selection");
class ReplaceTextAction {
    constructor(username, insertingText) {
        this.username = username;
        this.insertingText = insertingText;
    }
    //TODO: - реализовать смещение выделений у пользователей
    execute(model) {
        this.deleteSelection(model);
        this.insertText(model);
    }
    static fromJson(json) {
        return new ReplaceTextAction(json.username, json.text);
    }
    toJson() {
        return JSON.stringify({
            "action": "replace_text",
            "username": this.username,
            "text": this.insertingText
        });
    }
    deleteSelection(model) {
        var selectedRange = model.users.find((user) => user.username == this.username).selection;
        if (selectedRange.start == selectedRange.end) {
            return;
        }
        var prefix = model.file.lines[selectedRange.start.y].substring(0, selectedRange.start.x);
        var suffix = model.file.lines[selectedRange.end.y].substring(selectedRange.end.x);
        model.file.lines.splice(selectedRange.start.y, selectedRange.end.y - selectedRange.start.y + 1);
        model.file.lines.splice(selectedRange.start.y, 0, prefix + suffix);
        for (var i = 0; i < model.users.length; i++) {
            var user = model.users[i];
            if (user.username == this.username || selectedRange.constaint(user.cursorPosition)) {
                user.cursorPosition = new point_1.Point(selectedRange.start.x, selectedRange.start.y);
                if (user.username == this.username) {
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
                else {
                    //TODO: - сделать нормальное обновление выделения
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
            }
            else {
                if (user.cursorPosition.y == selectedRange.end.y && user.cursorPosition.x >= selectedRange.end.x) {
                    user.cursorPosition = new point_1.Point(prefix.length + user.cursorPosition.x - selectedRange.end.x, selectedRange.start.y);
                    //TODO: - сделать нормальное обновление выделения
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
                else if (user.cursorPosition.y > selectedRange.end.y) {
                    user.cursorPosition = new point_1.Point(user.cursorPosition.x, user.cursorPosition.y - (selectedRange.end.y - selectedRange.start.y));
                    //TODO: - сделать нормальное обновление выделения
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
            }
        }
    }
    insertText(model) {
        var selectedRange = model.users.find((user) => user.username == this.username).selection;
        var lines = this.insertingText.split("\n");
        var prefix = model.file.lines[selectedRange.start.y].substring(0, selectedRange.start.x);
        var suffix = model.file.lines[selectedRange.start.y].substring(selectedRange.start.x);
        if (lines.length == 1) {
            model.file.lines[selectedRange.start.y] = prefix + lines[0] + suffix;
            for (var i = 0; i < model.users.length; i++) {
                var user = model.users[i];
                if (user.username == this.username) {
                    user.cursorPosition = new point_1.Point(selectedRange.start.x + this.insertingText.length, selectedRange.start.y);
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
                else {
                    if (user.cursorPosition.y == selectedRange.start.y && user.cursorPosition.x > selectedRange.start.x) {
                        user.cursorPosition = new point_1.Point(user.cursorPosition.x + this.insertingText.length, user.cursorPosition.y);
                        //TODO: - сделать нормальное обновление выделения
                        user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                    }
                }
            }
        }
        else {
            model.file.lines[selectedRange.start.y] = prefix + lines[0];
            for (var i = 1; i < lines.length - 1; i++) {
                model.file.lines.splice(selectedRange.start.y + i - 1, 0, lines[i]);
            }
            model.file.lines.splice(selectedRange.start.y + lines.length - 1, 0, lines[lines.length - 1] + suffix);
            for (var i = 0; i < model.users.length; i++) {
                var user = model.users[i];
                if (user.username == this.username) {
                    user.cursorPosition = new point_1.Point(lines[lines.length - 1].length, selectedRange.start.y + lines.length - 1);
                    user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                }
                else {
                    if (user.cursorPosition.y == selectedRange.start.y && user.cursorPosition.x > selectedRange.start.x) {
                        user.cursorPosition = new point_1.Point(lines[lines.length - 1].length + user.cursorPosition.x - selectedRange.end.x, user.cursorPosition.y + lines.length - 1);
                        //TODO: - сделать нормальное обновление выделения
                        user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                    }
                    else if (user.cursorPosition.y > selectedRange.start.y) {
                        user.cursorPosition = new point_1.Point(user.cursorPosition.x, user.cursorPosition.y + lines.length - 1);
                        //TODO: - сделать нормальное обновление выделения
                        user.selection = new selection_1.Selection(user.cursorPosition, user.cursorPosition);
                    }
                }
            }
        }
    }
}
exports.ReplaceTextAction = ReplaceTextAction;
