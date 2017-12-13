import QtQuick 2.4

Item {

    readonly property var dict: {
        //: Refers to a mouse button
        "left button" : qsTr("Left Button"),
        //: Refers to a mouse button
        "right button" : qsTr("Right Button"),
        //: Refers to a mouse button
        "middle button" : qsTr("Middle Button"),
        //: Refers to the mouse wheel
        "wheel up" : qsTr("Wheel Up"),
        //: Refers to the mouse wheel
        "wheel down" : qsTr("Wheel Down")
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
