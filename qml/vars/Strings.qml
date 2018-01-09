import QtQuick 2.6

Item {

    // KEY STRINGS
    readonly property var dictKeys: {
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

    // MOUSE STRINGS
    readonly property var dictMouse: {
        //: Refers to a mouse button
        "left button" : qsTr("Left Button"),
        //: Refers to a mouse button
        "right button" : qsTr("Right Button"),
        //: Refers to a mouse button
        "middle button" : qsTr("Middle Button"),
        //: Refers to the mouse wheel
        "wheel up" : qsTr("Wheel Up"),
        //: Refers to the mouse wheel
        "wheel down" : qsTr("Wheel Down"),
        //: Refers to a direction of a mouse gesture
        "east" : qsTr("East"),
        //: Refers to a direction of a mouse gesture
        "south" : qsTr("South"),
        //: Refers to a direction of a mouse gesture
        "west" : qsTr("West"),
        //: Refers to a direction of a mouse gesture
        "north" : qsTr("North"),
    }


    function get(combo) {
        var tmp = combo.toLowerCase()
        if(tmp in dictKeys)
            return dictKeys[tmp]
        if(tmp in dictMouse)
            return dictMouse[tmp]
        return combo
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

        var comboLC = combo.toLowerCase()
        if((comboLC.indexOf("left button") > -1 && comboLC.indexOf("left button") != comboLC.length-11)
                || (comboLC.indexOf("right button") > -1 && comboLC.indexOf("right button") != comboLC.length-12)) {

            var p = ret.split("+")
            var lastItem = p[p.length-1]
            ret = ""
            for(var j = 0; j < p.length-1; ++j)
                ret += p[j] + "+"

            for(var k = 0; k < lastItem.length; ++k) {
                if(k > 0) ret += "-"
                if(lastItem[k] == "E")
                    ret += dictMouse["east"]
                else if(lastItem[k] == "S")
                    ret += dictMouse["south"]
                else if(lastItem[k] == "W")
                    ret += dictMouse["west"]
                else if(lastItem[k] == "N")
                    ret += dictMouse["north"]
            }

        }

        return ret

    }

}
