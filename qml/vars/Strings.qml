import QtQuick 2.5

Item {

    // KEY STRINGS
    readonly property var dictKeys: {
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
        //: 'Return' refers to the enter key of the number block - please try to make the translations of 'Return' and 'Enter' (the main button) different if possible!
        "return" : em.pty+qsTr("Return"),
        //: 'Enter' refers to the main enter key - please try to make the translations of 'Return' (in the number block) and 'Enter' different if possible!
        "enter" : em.pty+qsTr("Enter"),
    }

    // MOUSE STRINGS
    readonly property var dictMouse: {
        //: Refers to a mouse button
        "left button" : em.pty+qsTr("Left Button"),
        //: Refers to a mouse button
        "right button" : em.pty+qsTr("Right Button"),
        //: Refers to a mouse button
        "middle button" : em.pty+qsTr("Middle Button"),
        //: Refers to the mouse wheel
        "wheel up" : em.pty+qsTr("Wheel Up"),
        //: Refers to the mouse wheel
        "wheel down" : em.pty+qsTr("Wheel Down"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "east" : em.pty+qsTr("East"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "south" : em.pty+qsTr("South"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "west" : em.pty+qsTr("West"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "north" : em.pty+qsTr("North"),
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

        var comboSave = combo

        combo = combo.replace("++","+PLUS")
        if(combo === "+") combo = "PLUS"
        var parts = combo.split("+")
        var ret = ""
        for(var i in parts) {
            if(ret != "")
                ret += "+"
            if(parts[i] === "")
                continue
            if(parts[i] === "PLUS")
                ret += "+"
            else
                ret += get(parts[i])
        }

        var comboLC = combo.toLowerCase()
        if((comboLC.indexOf("left button") > -1 && comboLC.indexOf("left button") !== comboLC.length-11)
                || (comboLC.indexOf("right button") > -1 && comboLC.indexOf("right button") !== comboLC.length-12)) {

            var p = ret.split("+")
            var lastItem = p[p.length-1]
            ret = ""
            for(var j = 0; j < p.length-1; ++j)
                ret += p[j] + "+"

            for(var k = 0; k < lastItem.length; ++k) {
                if(k > 0) ret += "-"
                if(lastItem[k] === "E")
                    ret += dictMouse["east"]
                else if(lastItem[k] === "S")
                    ret += dictMouse["south"]
                else if(lastItem[k] === "W")
                    ret += dictMouse["west"]
                else if(lastItem[k] === "N")
                    ret += dictMouse["north"]
            }

        }

        verboseMessage("vars/Strings", "translateShortcut(): " + comboSave + " / " + ret)

        return ret

    }

}
