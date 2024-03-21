import QtQuick
import PQCNotify

Item {

    clip: true

    property bool animateWidth: false
    property bool animateHeight: false

    width: (enabled||!animateWidth) ? controlrow.width : 0
    height: (enabled||!animateHeight) ? controlrow.height : 0
    opacity: (enabled||(!animateWidth&&!animateHeight)) ? 1 : 0

    Behavior on width { NumberAnimation { duration: 200 } }
    Behavior on height { NumberAnimation { duration: 200 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }

    visible: width>0&&height>0

    property int minval: 1
    property int maxval: 10

    property alias title: pretext.text
    property alias value: spinbox.value
    property string suffix: ""

    onVisibleChanged: {
        if(!visible) {
            PQCNotify.spinBoxPassKeyEvents = false
            txt.visible = true
        }
    }

    Row {

        id: controlrow

        spacing: 10

        PQText {
            id: pretext
            y: (parent.height-height)/2
            text: ""
        }

        Item {

            width: spinbox.width
            height: spinbox.height

            PQSpinBox {
                id: spinbox
                from: minval
                to: maxval
                width: 120
                visible: !txt.visible
                Component.onDestruction:
                    PQCNotify.spinBoxPassKeyEvents = false
                Keys.onEnterPressed:
                    acceptbut.clicked()
                Keys.onReturnPressed:
                    acceptbut.clicked()
            }

            PQButton {
                id: txt
                anchors.fill: parent
                smallerVersion: true
                text: spinbox.value + suffix
                //: Tooltip, used as in: Click to edit this value
                tooltip: qsTranslate("settingsmanager", "Click to edit")
                onClicked: {
                    PQCNotify.spinBoxPassKeyEvents = true
                    txt.visible = false
                }
            }

        }

        PQButton {
            id: acceptbut
            text: genericStringSave
            smallerVersion: true
            height: spinbox.height
            visible: !txt.visible
            onClicked: {
                PQCNotify.spinBoxPassKeyEvents = false
                txt.visible = true
            }
        }

    }

    function acceptValue() {
        PQCNotify.spinBoxPassKeyEvents = false
        txt.visible = true
    }

    function hasChanged() {
        return spinbox.hasChanged()
    }

    function loadAndSetDefault(val) {
        acceptbut.clicked()
        spinbox.loadAndSetDefault(val)
    }

    function saveDefault() {
        acceptbut.clicked()
        spinbox.saveDefault()
    }

}
