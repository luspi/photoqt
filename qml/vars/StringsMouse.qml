import QtQuick 2.5

Item {

    readonly property var dict: {
        //: Refers to a mouse button
        "left button" : em.pty+qsTr("Left Button"),
        //: Refers to a mouse button
        "right button" : em.pty+qsTr("Right Button"),
        //: Refers to a mouse button
        "middle button" : em.pty+qsTr("Middle Button"),
        //: Refers to the mouse wheel
        "wheel up" : em.pty+qsTr("Wheel Up"),
        //: Refers to the mouse wheel
        "wheel down" : em.pty+qsTr("Wheel Down")
    }

    function get(key) {
        key = key.toLowerCase()
        if(key in dict)
            return dict[key]
        return key
    }

    function translateMouseCombo(combo) {

        combo = combo.replace("++","+PLUS")
        var parts = combo.split("+")
        var ret = ""
        for(var i in parts) {
            if(ret != "")
                ret += "+"
            if(parts[i] == "")
                continue
            if(parts[i] == "PLUS")
                ret += "+"
            else {
                var tmp_k = str_keys.get(parts[i])
                var tmp_m = get(parts[i])
                if(tmp_k != parts[i].toLowerCase())
                    ret += tmp_k
                else if(tmp_m != parts[i].toLowerCase())
                    ret += tmp_m
                else
                    ret += parts[i]
            }
        }

        return ret

    }

}
