import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {

    id: control

    editable: true

    property string prefix: ""
    property string suffix: ""

    width: 100
    height: 30

    textFromValue:
        function(value, locale) {
            var ret = ""
            if(prefix != "")
                ret += prefix
            ret += value
            if(suffix != "")
                ret += suffix
            return ret
        }

}
