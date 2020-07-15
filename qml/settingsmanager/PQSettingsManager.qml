import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
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

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        Column {

            id: bar

            width: 300
            height: parent.height-buttons_container.height

            property int currentIndex: 0

            property var tabs: [["interface", "Tab to control interface settings"],
                                ["image view", "Tab to control how images are viewed"],
                                ["thumbnails", "Tab to control the look and behaviour of thumbnails"],
                                ["metadata", "Tab to control metadata settings"],
                                ["file types", "Tab to control which file types PhotoQt should recognize"],
                                ["shortcuts", "Tab to control which shortcuts are set"]]

            Repeater {

                model: bar.tabs.length

                Rectangle {

                    width: bar.width
                    height: bar.height/bar.tabs.length

                    border {
                        width: 1
                        color: "#555555"
                    }

                    color: bar.currentIndex==index
                                ? "#555555"
                                : (mouse.containsPress
                                   ? "#444444"
                                   : (mouse.containsMouse
                                      ? "#3a3a3a"
                                      : "#333333"))

                    PQMouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: bar.tabs[index][1]
                        onClicked:
                            bar.currentIndex = index
                    }

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "#ffffff"
                        wrapMode: Text.WordWrap
                        font.pointSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        text: bar.tabs[index][0]
                    }
                }

            }

        }

        Item {

            id: stack

            clip: true

            anchors {
                top: parent.top
                bottom: buttons_container.top
                right: parent.right
                left: bar.right
            }

            PQTabInterface {
                visible: bar.currentIndex==0
            }

            property var srcs: ["tabs/PQTabImageView.qml", "tabs/PQTabThumbnails.qml", "tabs/PQTabMetadata.qml", "tabs/PQTabFileTypes.qml", "tabs/PQTabShortcuts.qml"]

            Repeater {
                model: stack.srcs.length
                Loader {
                    id: load

                    visible: bar.currentIndex==(index+1)

                    Connections {
                        // We use a connections object instead of property bindings in order to be reliably able to show a 'busy' cursor while loading
                        target: bar
                        onCurrentIndexChanged: {
                            if(bar.currentIndex == index+1 && load.source == "") {
                                handlingGeneral.setOverrideCursor(true)
                                load.source = stack.srcs[index]
                                handlingGeneral.setOverrideCursor(false)
                            }
                        }
                    }
                }
            }

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
