import QtQuick 2.9
import QtQuick.Controls 2.2

Item {

    width: parent.width
    height: ((expertmodeonly && variables.settingsManagerExpertMode) || (!normalmodeonly && variables.settingsManagerExpertMode) || (!expertmodeonly && !variables.settingsManagerExpertMode)) ? row.height+20 : 0
    Behavior on height { NumberAnimation { duration: 200 } }
    visible: height>0
    clip: true

    property alias title: txt.text
    property alias content: cont.children
    property string helptext: ""

    property bool expertmodeonly: false
    property bool normalmodeonly: false

    Row {

        id: row

        y: 10
        width: parent.width
//        height: childrenRect.height

        Text {
            id: txt
            y: (parent.height-height)/2
            text: ""
            color: "white"
            width: 300
            font.bold: true
            font.pointSize: 12

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                tooltip: helptext
                cursorShape: Qt.WhatsThisCursor
            }
        }

        Item {
            x: txt.width
            y: (parent.height-height)/2
            width: parent.width - txt.width
            height: childrenRect.height
            id: cont
        }

    }

}
