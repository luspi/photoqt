import QtQuick 2.4
import QtQuick.Controls 1.3

import "./fileformats"
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
                //: Used as heading of tab in the settings manager
                text: qsTr("Fileformats")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Text {
                width: flickable.width
                color: "white"
                font.pointSize: 9
                text: qsTranslate("SettingsManager", "Move your mouse cursor over the different settings titles to see more information.")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { color: "transparent"; width: 1; height: 30; }

            Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            FileTypesQt { id: filetypesqt }
            FileTypesExtras { id: filetypesextras; alternating: true }
            FileTypesGM { id: filetypesgm }
            FileTypesGMGhostscript { id: filetypesgmghostscript; alternating: true }
            FileTypesRaw { id: filetypesraw }
            FileTypesUntested { id: filetypesuntested; alternating: true }


        }

    }

    function setData() {
        filetypesqt.setData()
        filetypesgm.setData()
        filetypesgmghostscript.setData()
        filetypesextras.setData()
        filetypesuntested.setData()
        filetypesraw.setData()
    }

    function saveData() {
        filetypesqt.saveData()
        filetypesgm.saveData()
        filetypesgmghostscript.saveData()
        filetypesextras.saveData()
        filetypesuntested.saveData()
        filetypesraw.saveData()
    }

}
