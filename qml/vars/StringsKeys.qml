import QtQuick 2.5

Item {

    readonly property var dict: {
        //: Refers to a keyboard modifier
        "alt" : qsTr("Alt"),
        //: Refers to a keyboard modifier
        "ctrl" : qsTr("Ctrl"),
        //: Refers to a keyboard modifier
        "shift" : qsTr("Shift"),
        //: Refers to one of the keys on the keyboard
        "page up" : qsTr("Page Up"),
        //: Refers to one of the keys on the keyboard
        "page down" : qsTr("Page Down"),
        //: Refers to the key that usually has the 'Windows' symbol on it
        "meta" : qsTr("Meta"),
        //: Refers to the key that triggers the number block on keyboards
        "keypad" : qsTr("Keypad"),
        //: Refers to one of the keys on the keyboard
        "escape" : qsTr("Escape"),
        //: Refers to one of the arrow keys on the keyboard
        "right" : qsTr("Right"),
        //: Refers to one of the arrow keys on the keyboard
        "left" : qsTr("Left"),
        //: Refers to one of the arrow keys on the keyboard
        "up" : qsTr("Up"),
        //: Refers to one of the arrow keys on the keyboard
        "down" : qsTr("Down"),
        //: Refers to one of the keys on the keyboard
        "space" : qsTr("Space"),
        //: Refers to one of the keys on the keyboard
        "delete" : qsTr("Delete"),
        //: Refers to one of the keys on the keyboard
        "backspace" : qsTr("Backspace"),
        //: Refers to one of the keys on the keyboard
        "home" : qsTr("Home"),
        //: Refers to one of the keys on the keyboard
        "end" : qsTr("End"),
        //: Refers to one of the keys on the keyboard
        "insert" : qsTr("Insert"),
        //: Refers to one of the keys on the keyboard
        "tab" : qsTr("Tab"),
        //: 'Return' refers to the enter key of the number block - please try to make the translations of 'Return' and 'Enter' (the main button) different!
        "return" : qsTr("Return"),
        //: 'Enter' refers to the main enter key - please try to make the translations of 'Return' (in the number block) and 'Enter' different!
        "enter" : qsTr("Enter"),
    }

    function get(key) {
        var tmp = key.toLowerCase()
        if(tmp in dict)
            return dict[tmp]
        return key
    }

    function translateShortcut(combo) {

        combo = combo.replace("++","+PLUS")
        if(combo == "+") combo = "PLUS"
        var parts = combo.split("+")
        var ret = ""
        for(var i in parts) {
            if(ret != "")
                ret += "+"
            if(parts[i] == "")
                continue
            if(parts[i] == "PLUS")
                ret += "+"
            else
                ret += get(parts[i])
        }

        return ret

    }

}
