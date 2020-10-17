import QtQuick 2.9
import QtQuick.Controls 2.2

Item {

    id: set_top

    width: stack.width-20
    height: ((expertmodeonly && variables.settingsManagerExpertMode) || (!normalmodeonly && variables.settingsManagerExpertMode) || (!expertmodeonly && !variables.settingsManagerExpertMode)) ? cont.height+20 : 0
    Behavior on height { NumberAnimation { duration: 200 } }
    visible: height>0
    clip: true

    property alias title: txt.text
    property alias content: cont.children
    property string helptext: ""

    property alias contwidth: cont.width

    property bool expertmodeonly: false
    property bool normalmodeonly: false

    Row {

        id: row

        y: 10

        Text {
            id: txt
            y: (parent.height-height)/2
            text: ""
            color: "white"
            width: 260
            font.bold: true
            font.pointSize: 12
            horizontalAlignment: Text.AlignRight

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                tooltip: helptext
                cursorShape: Qt.WhatsThisCursor
            }
        }

        Item {
            width: 40
            height: 1
        }

        Item {
            id: cont_container
            y: (parent.height-height)/2
            width: set_top.width - txt.width-40
            height: cont.height
            Item {
                id: cont
                width: parent.width
                height: childrenRect.height
            }
        }

    }

}
