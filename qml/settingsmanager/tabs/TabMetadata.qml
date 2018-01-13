import QtQuick 2.4
import QtQuick.Controls 1.3

import "./metadata"
import "../../elements"


Rectangle {

    id: tab_top

    property int titlewidth: 100

    color: "#00000000"

    anchors {
        fill: parent
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+20
        contentWidth: maincol.width

        Column {

            id: maincol

            Rectangle { color: "transparent"; width: 1; height: 10; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 20
                font.bold: true
                text: qsTr("Image Metadata")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 9
                text: qsTranslate("SettingsManager", "Move your mouse cursor over (or click on) the different settings titles to see more information.")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Text {
                color: "white"
                width: flickable.width-20
                x: 10
                wrapMode: Text.WordWrap
                //: Introduction text of metadata tab in settings manager
                text: qsTr("PhotoQt can display different information of and about each image. The element for this information is hidden on the left side of the screen and fades in when the mouse cursor gets close to the left screen edge and/or when the set shortcut is triggered. On demand, the triggering by mouse movement can be disabled by checking the box below.")
            }

            Rectangle { color: "transparent"; width: 1; height: 30; }

            Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            MouseTrigger { id: trigger }
            MetaData { id: metadata; alternating: true }
            FontSize { id: fontsize }
            Opacity { id: op; alternating: true }
            RotateFlip { id: rotateflip }
            OnlineMap { id: onlinemap; alternating: true }


        }

    }

    function setData() {
        trigger.setData()
        metadata.setData()
        fontsize.setData()
        op.setData()
        rotateflip.setData()
        onlinemap.setData()
    }

    function saveData() {
        trigger.saveData()
        metadata.saveData()
        fontsize.saveData()
        op.saveData()
        rotateflip.saveData()
        onlinemap.saveData()
    }

}
