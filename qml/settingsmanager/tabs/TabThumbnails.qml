import QtQuick 2.3
import QtQuick.Controls 1.2

import "./thumbnails"
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
                text: qsTr("Thumbnails")
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

            Rectangle { color: "transparent"; width: 1; height: 20; }

            Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

            Rectangle { color: "transparent"; width: 1; height: 20; }

            ThumbnailSize { id: thumbnailsize }
            Spacing { id: spacing; alternating: true }
            LiftUp { id: liftup }
            KeepVisible { id: keepvisible; alternating: true }
            CenterOn { id: centeron }
            TopOrBottom { id: toporbottom; alternating: true }
            Label { id: label }
            FilenameOnly { id: filenameonly; alternating: true }
            Disable { id: disable }
            Cache { id: cache; alternating: true }


        }

    }

    function setData() {
        thumbnailsize.setData()
        spacing.setData()
        liftup.setData()
        keepvisible.setData()
        centeron.setData()
        toporbottom.setData()
        label.setData()
        filenameonly.setData()
        disable.setData()
        cache.setData()
    }

    function saveData() {
        thumbnailsize.saveData()
        spacing.saveData()
        liftup.saveData()
        keepvisible.saveData()
        centeron.saveData()
        toporbottom.saveData()
        label.saveData()
        filenameonly.saveData()
        disable.saveData()
        cache.saveData()
    }

    function eraseDatabase() {
        thumbnailmanagement.eraseDatabase()
        updateDatabaseInfo()
    }

    function cleanDatabase() {
        thumbnailmanagement.cleanDatabase()
        updateDatabaseInfo()
    }

    function updateDatabaseInfo() {
        cache.updateDatabaseInfo()
    }

}
