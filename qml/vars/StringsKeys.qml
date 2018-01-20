import QtQuick 2.5

Item {

    readonly property var dict: {
        //: Refers to a keyboard modifier
        "alt" : em.pty+qsTr("Alt"),
        //: Refers to a keyboard modifier
        "ctrl" : em.pty+qsTr("Ctrl"),
        //: Refers to a keyboard modifier
        "shift" : em.pty+qsTr("Shift"),
        //: Refers to one of the keys on the keyboard
        "page up" : em.pty+qsTr("Page Up"),
        //: Refers to one of the keys on the keyboard
        "page down" : em.pty+qsTr("Page Down"),
        //: Refers to the key that usually has the 'Windows' symbol on it
        "meta" : em.pty+qsTr("Meta"),
        //: Refers to the key that triggers the number block on keyboards
        "keypad" : em.pty+qsTr("Keypad"),
        //: Refers to one of the keys on the keyboard
        "escape" : em.pty+qsTr("Escape"),
        //: Refers to one of the arrow keys on the keyboard
        "right" : em.pty+qsTr("Right"),
        //: Refers to one of the arrow keys on the keyboard
        "left" : em.pty+qsTr("Left"),
        //: Refers to one of the arrow keys on the keyboard
        "up" : em.pty+qsTr("Up"),
        //: Refers to one of the arrow keys on the keyboard
        "down" : em.pty+qsTr("Down"),
        //: Refers to one of the keys on the keyboard
        "space" : em.pty+qsTr("Space"),
        //: Refers to one of the keys on the keyboard
        "delete" : em.pty+qsTr("Delete"),
        //: Refers to one of the keys on the keyboard
        "backspace" : em.pty+qsTr("Backspace"),
        //: Refers to one of the keys on the keyboard
        "home" : em.pty+qsTr("Home"),
        //: Refers to one of the keys on the keyboard
        "end" : em.pty+qsTr("End"),
        //: Refers to one of the keys on the keyboard
        "insert" : em.pty+qsTr("Insert"),
        //: Refers to one of the keys on the keyboard
        "tab" : em.pty+qsTr("Tab"),
        //: 'Return' refers to the enter key of the number block - please try to make the translations of 'Return' and 'Enter' (the main button) different!
        "return" : em.pty+qsTr("Return"),
        //: 'Enter' refers to the main enter key - please try to make the translations of 'Return' (in the number block) and 'Enter' different!
        "enter" : em.pty+qsTr("Enter"),
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
