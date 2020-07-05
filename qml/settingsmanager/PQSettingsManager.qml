import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.9
import Qt.labs.platform 1.1
import QtGraphicalEffects 1.0

import "../elements"
import "./tabs"

Item {

    id: settingsmanager_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    signal loadAllSettings()
    signal saveAllSettings()

    property bool modalWindowOpen: false
    signal closeModalWindow()

    property bool detectingShortcutCombo: false
    signal newModsKeysCombo(var mods, var keys)

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.settingsManagerPopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#aa000000"

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
                tooltip: "Tab to control interface settings"
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
                tooltip: "Tab to control how images are viewed"
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
                tooltip: "Tab to control the look and behaviour of thumbnails"
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
                tooltip: "Tab to control metadata settings"
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
                tooltip: "Tab to control which file types are to be recognized"
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
                tooltip: "Tab to control which shortcuts are set"
                selected: bar.currentIndex==5
                onClicked: bar.currentIndex = 5
            }

            onCurrentIndexChanged: {
                if(currentIndex == 1 && tab_imageview.source == "") {
                    handlingGeneral.setOverrideCursor(true)
                    tab_imageview.source = "tabs/PQTabImageView.qml"
                    handlingGeneral.setOverrideCursor(false)
                } else if(currentIndex == 2 && tab_thumbnails.source == "") {
                    handlingGeneral.setOverrideCursor(true)
                    tab_thumbnails.source = "tabs/PQTabThumbnails.qml"
                    handlingGeneral.setOverrideCursor(false)
                } else if(currentIndex == 3 && tab_metadata.source == "") {
                    handlingGeneral.setOverrideCursor(true)
                    tab_metadata.source = "tabs/PQTabMetadata.qml"
                    handlingGeneral.setOverrideCursor(false)
                } else if(currentIndex == 4 && tab_filetypes.source == "") {
                    handlingGeneral.setOverrideCursor(true)
                    tab_filetypes.source = "tabs/PQTabFileTypes.qml"
                    handlingGeneral.setOverrideCursor(false)
                } else if(currentIndex == 5 && tab_shortcuts.source == "") {
                    handlingGeneral.setOverrideCursor(true)
                    tab_shortcuts.source = "tabs/PQTabShortcuts.qml"
                    handlingGeneral.setOverrideCursor(false)
                }
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
            Loader { id: tab_imageview }
            Loader { id: tab_thumbnails }
            Loader { id: tab_metadata }
            Loader { id: tab_filetypes }
            Loader { id: tab_shortcuts }
        }


        Rectangle {

            x: 0
            y: parent.height - height
            width: bar.width
            height: buttons_container.height

            color: "#111111"

            PQButton {
                x: (parent.width-width)/2
                y: (parent.height-height)/2
                text: "advanced"
                clickOpensMenu: true
                menuOpenDownward: false
                buttonSameWidthAsMenu: true
                listMenuItems: ["import settings", "export settings", (variables.settingsManagerExpertMode ? "disable expert mode" : "enable expert mode")]
                onMenuItemClicked: {
                    if(pos == 0) {
                        console.log("import")
                        openFileDialog.visible = true
                    } else if(pos == 1) {
                        console.log("export")
                        saveFileDialog.visible = true
                    } else if(pos == 2) {
                        variables.settingsManagerExpertMode = !variables.settingsManagerExpertMode
                    }
                }
            }

        }

        FileDialog {
            id: saveFileDialog
            folder: "file://"+handlingFileDialog.getHomeDir()
            modality: Qt.ApplicationModal
            fileMode: FileDialog.SaveFile
            nameFilters: ["PhotoQt backup (*.pqt)"]
            onAccepted: {
                if(saveFileDialog.file != "")
                    handlingExternal.exportConfigTo(handlingFileDialog.cleanPath(saveFileDialog.file))
            }
            onVisibleChanged: {
                if(visible)
                    currentFile = "file://" + handlingFileDialog.getHomeDir() + "/PhotoQt_backup_" + new Date().toLocaleString(Qt.locale(), "yyyy_MM_dd") + ".pqt"
            }
        }

        FileDialog {
            id: openFileDialog
            folder: "file://"+handlingFileDialog.getHomeDir()
            modality: Qt.ApplicationModal
            fileMode: FileDialog.OpenFile
            nameFilters: ["PhotoQt backup (*.pqt)"]
            onAccepted: {
                if(openFileDialog.file != "") {
                    var yes = handlingGeneral.askForConfirmation("Import of '" + handlingGeneral.getFileNameFromFullPath(openFileDialog.file) + "'. This will replace your current settings with the ones stored in the backup.",
                                                                 "Do you want to continue?")
                    if(yes) {
                        handlingExternal.importConfigFrom(handlingFileDialog.cleanPath(openFileDialog.file) )
                        rst.start()
                    }
                }
            }
        }

        // Reload settings after short timeout. This ensures that the changed settings/... files have been detected and variables have been updated.
        Timer {
            id: rst
            interval: 500
            repeat: false
            onTriggered: resetSettings()
        }

        Rectangle {

            id: buttons_container

            x: bar.width
            y: parent.height-height
            width: parent.width-bar.width
            height: 50

            color: "#111111"

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

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
