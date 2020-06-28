import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.9

import "../elements"
import "./tabs"

Rectangle {

    id: settingsmanager_top

    color: "#dd000000"

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    signal loadAllSettings()
    signal saveAllSettings()

    property bool modalWindowOpen: false
    signal closeModalWindow()

    property bool detectingShortcutCombo: false
    signal newModsKeysCombo(var mods, var keys)

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    TabBar {
        id: bar
        x: 0
        y: 0
        width: 250
        height: parent.height-buttons_container.height
        background: Rectangle {
            color: "black"
        }
        PQTabButton {
            id: tabbutton_interface
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "interface"
            selected: bar.currentIndex==0
            onClicked: bar.currentIndex = 0
        }
        PQTabButton {
            id: tabbutton_imageview
            anchors.top: tabbutton_interface.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "image view"
            selected: bar.currentIndex==1
            onClicked: bar.currentIndex = 1
        }
        PQTabButton {
            id: tabbutton_thumbnail
            anchors.top: tabbutton_imageview.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "thumbnails"
            selected: bar.currentIndex==2
            onClicked: bar.currentIndex = 2
        }
        PQTabButton {
            id: tabbutton_metadata
            anchors.top: tabbutton_thumbnail.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "metadata"
            selected: bar.currentIndex==3
            onClicked: bar.currentIndex = 3
        }
        PQTabButton {
            id: tabbutton_filetypes
            anchors.top: tabbutton_metadata.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "file types"
            selected: bar.currentIndex==4
            onClicked: bar.currentIndex = 4
        }
        PQTabButton {
            id: tabbutton_shortcuts
            anchors.top: tabbutton_filetypes.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "shortcuts"
            selected: bar.currentIndex==5
            onClicked: bar.currentIndex = 5
        }
        PQTabButton {
            id: tabbutton_manage
            anchors.top: tabbutton_shortcuts.bottom
            implicitWidth: bar.width
            implicitHeight: bar.height/bar.count
            anchors.horizontalCenter: parent.horizontalCenter
            text: "manage settings"
            selected: bar.currentIndex==6
            onClicked: bar.currentIndex = 6
        }
    }

    StackLayout {
        id: stack
        x: bar.width
        y: 0
        width: parent.width-bar.width
        height: parent.height-buttons_container.height
        currentIndex: bar.currentIndex
        PQTabInterface { id: tab_interface }
        PQTabImageView { id: tab_imageview }
        PQTabThumbnails { id: tab_thumbnails }
        PQTabMetadata { id: tab_metadata }
        PQTabFileTypes { id: tab_filetypes }
        PQTabShortcuts { id: tab_shortcuts }
        PQTabManageSettings { id: tab_manage }
    }


    Rectangle {

        x: 0
        y: parent.height - height
        width: bar.width
        height: buttons_container.height

        color: "#111111"

        PQCheckbox {

            x: (parent.width-width)/2
            y: (parent.height-height)/2
            text: "expert mode"

            checked: variables.settingsManagerExpertMode
            onCheckedChanged:
                variables.settingsManagerExpertMode = checked

        }

    }


    Rectangle {

        id: buttons_container

        x: bar.width
        y: parent.height-height
        width: parent.width-bar.width
        height: 50

        color: "#111111"

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: "#555555"
        }

        Row {

            spacing: 5

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            PQButton {
                id: button_ok
                //: Written on a clickable button - please keep short
                text: "Save Changes and Exit"
                onClicked: {
                    if(!modalWindowOpen) {
                        saveSettings()
                        settingsmanager_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }
            }
            PQButton {
                id: button_cancel
                text: "Exit and Discard Changes"
                onClicked: {
                    if(modalWindowOpen)
                        closeModalWindow()
                    else {
                        settingsmanager_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }
            }

        }

    }

    Connections {
        target: loader
        onSettingsManagerPassOn: {
            if(what == "show") {
                resetSettings()
                opacity = 1
                variables.visibleItem = "settingsmanager"
            } else if(what == "hide") {
                button_cancel.clicked()
            } else if(what == "keyevent") {
                if(detectingShortcutCombo)
                    newModsKeysCombo(param[1], param[0])
                else if(param[0] == Qt.Key_Escape)
                    button_cancel.clicked()
                else if(param[0] == Qt.Key_S && param[1] == Qt.ControlModifier)
                    button_ok.clicked()
                else if(param[0] == Qt.Key_Tab && (param[1] & Qt.ControlModifier))
                    bar.currentIndex = (bar.currentIndex+1)%bar.count
                else if(param[0] == Qt.Key_Backtab && (param[1] & Qt.ControlModifier))
                    bar.currentIndex = (bar.count + bar.currentIndex-1)%bar.count
                else if(param[0] == Qt.Key_1 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 0
                else if(param[0] == Qt.Key_2 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 1
                else if(param[0] == Qt.Key_3 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 2
                else if(param[0] == Qt.Key_4 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 3
                else if(param[0] == Qt.Key_5 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 4
                else if(param[0] == Qt.Key_6 && (param[1] & Qt.AltModifier))
                    bar.currentIndex = 5

            }
        }
    }

    function saveSettings() {

        // let everybody know to save
        saveAllSettings()

    }

    function resetSettings() {

        // let everybody know to load
        loadAllSettings()

    }

}
