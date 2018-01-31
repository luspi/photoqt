import QtQuick 2.5
import QtQuick.Controls 1.4

import "./other"
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
                text: em.pty+qsTr("Other Settings")
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

            Rectangle { color: "transparent"; width: 1; height: 30; }

            Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Language { id: language }
            CustomEntries { id: customentries; alternating: true; enabled: !getanddostuff.amIOnWindows() }
            Imgur { id: imgur; }

        }

    }

    function setData() {
        verboseMessage("SettingsManager/TabOther", "setData()")
        language.setData()
        customentries.setData()
        imgur.setData()
    }

    function saveData() {
        verboseMessage("SettingsManager/TabOther", "saveData()")
        language.saveData()
        customentries.saveData()
        imgur.saveData()
    }

}
