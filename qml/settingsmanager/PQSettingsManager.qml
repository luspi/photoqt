/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import "../elements"
import "./tabs"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: settingsmanager_top

    width: parentWidth
    height: parentHeight

    onWidthChanged:
        isScrollBarVisible()
    onHeightChanged:
        isScrollBarVisible()

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    signal loadAllSettings()
    signal saveAllSettings()

    property bool modalWindowOpen: false
    signal closeModalWindow()

    property bool detectingShortcutCombo: false
    signal newModsKeysCombo(var mods, var keys)

    property bool scrollBarVisible: false
    signal isScrollBarVisible()

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {

        anchors.fill: parent
        color: "#181818"

        Column {

            id: bar

            width: 200
            height: parent.height-buttons_container.height

            property int currentIndex: 0
            property int count: tabs.length

            // we check for the scroll bar to know whether one is shown or not for each tab
            onCurrentIndexChanged:
                scollBarCheck.restart()
            // the timeout is needed as we check the 'visible' property for identifying the active tab
            // that property is still false right when currentIndex changes
            Timer {
                id: scollBarCheck
                interval: 100
                repeat: false
                running: false
                onTriggered:
                    settingsmanager_top.isScrollBarVisible()
            }

                                //: settings manager tab title
            property var tabs: [[em.pty+qsTranslate("settingsmanager", "interface"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control interface settings")],
                                //: settings manager tab title
                                [em.pty+qsTranslate("settingsmanager", "image view"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control how images are viewed")],
                                //: settings manager tab title
                                [em.pty+qsTranslate("settingsmanager", "thumbnails"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control the look and behaviour of thumbnails")],
                                //: settings manager tab title
                                [em.pty+qsTranslate("settingsmanager", "metadata"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control metadata settings")],
                                //: settings manager tab title
                                [em.pty+qsTranslate("settingsmanager", "file types"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control which file types PhotoQt should recognize")],
                                //: settings manager tab title
                                [em.pty+qsTranslate("settingsmanager", "shortcuts"),
                                 em.pty+qsTranslate("settingsmanager", "Tab to control which shortcuts are set")]]

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

                    PQText {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
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
                //: Written on button in setting manager. A click on this button opens a menu with some advanced actions.
                text: em.pty+qsTranslate("settingsmanager", "advanced")
                clickOpensMenu: true
                menuOpenDownward: false
                buttonSameWidthAsMenu: true
                listMenuItems: [em.pty+qsTranslate("settingsmanager", "restore defaults"),
                                em.pty+qsTranslate("settingsmanager", "import settings"),
                                em.pty+qsTranslate("settingsmanager", "export settings"),
                                (variables.settingsManagerExpertMode ? em.pty+qsTranslate("settingsmanager", "disable expert mode") : em.pty+qsTranslate("settingsmanager", "enable expert mode"))]
                onMenuItemClicked: {
                    if(pos == 0) {
                        restordefaults.show()
                    } else if(pos == 1) {
                        openFileDialog.visible = true
                    } else if(pos == 2) {
                        saveFileDialog.visible = true
                    } else if(pos == 3) {
                        variables.settingsManagerExpertMode = !variables.settingsManagerExpertMode
                    }
                }
            }

        }

        FileDialog {
            id: saveFileDialog
            folder: "file:///"+handlingFileDir.getHomeDir()
            currentFile: "file:///" + handlingFileDir.getHomeDir() + "/PhotoQt_backup_" + new Date().toLocaleString(Qt.locale(), "yyyy_MM_dd") + ".pqt"
            modality: Qt.ApplicationModal
            fileMode: FileDialog.SaveFile
            nameFilters: ["PhotoQt (*.pqt)"]
            onAccepted: {
                if(saveFileDialog.file != "")
                    handlingExternal.exportConfigTo(handlingFileDir.cleanPath(saveFileDialog.file))
            }
            onVisibleChanged: {
                if(visible && !handlingGeneral.amIOnWindows())
                    currentFile = "file:///" + handlingFileDir.getHomeDir() + "/PhotoQt_backup_" + new Date().toLocaleString(Qt.locale(), "yyyy_MM_dd") + ".pqt"
            }
        }

        FileDialog {
            id: openFileDialog
            folder: "file:///"+handlingFileDir.getHomeDir()
            modality: Qt.ApplicationModal
            fileMode: FileDialog.OpenFile
            nameFilters: ["PhotoQt (*.pqt)"]
            onAccepted: {
                if(openFileDialog.file != "") {
                    var yes = handlingGeneral.askForConfirmation(em.pty+qsTranslate("settingsmanager", "Import of %1. This will replace your current settings with the ones stored in the backup.").arg("'" + handlingFileDir.getFileNameFromFullPath(openFileDialog.file) + "'"),
                                                                 em.pty+qsTranslate("settingsmanager", "Do you want to continue?"))
                    if(yes) {
                        handlingExternal.importConfigFrom(handlingFileDir.cleanPath(openFileDialog.file) )
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

        PQRestoreDefaults { id: restordefaults }

        Rectangle {

            id: buttons_container

            x: bar.width
            y: parent.height-height
            width: parent.width-bar.width
            height: 75

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
                    text: em.pty+qsTranslate("settingsmanager", "Save changes and exit")
                    onClicked: {
                        if(!modalWindowOpen) {
                            saveSettings()
                            settingsmanager_top.opacity = 0
                            variables.visibleItem = ""
                            if(variables.settingsManagerOnTopOfFileDialog)
                                variables.visibleItem = "filedialog"
                        }
                    }
                }
                PQButton {
                    id: button_cancel
                    text: em.pty+qsTranslate("settingsmanager", "Exit and discard changes")
                    onClicked: {
                        if(modalWindowOpen)
                            closeModalWindow()
                        else {
                            settingsmanager_top.opacity = 0
                            variables.visibleItem = ""
                            if(variables.settingsManagerOnTopOfFileDialog)
                                variables.visibleItem = "filedialog"
                        }
                    }
                }

            }

        }

        Image {
            x: bar.width+5
            y: 5
            width: 15
            height: 15
            source: "/popin.svg"
            sourceSize: Qt.size(width, height)
            opacity: popinmouse.containsMouse ? 1 : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                id: popinmouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: PQSettings.interfacePopoutSettingsManager ?
                             //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                             em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                             //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                             em.pty+qsTranslate("popinpopout", "Move to its own window")
                onClicked: {
                    if(PQSettings.interfacePopoutSettingsManager)
                        settingsmanager_window.storeGeometry()
                    button_cancel.clicked()
                    PQSettings.interfacePopoutSettingsManager = !PQSettings.interfacePopoutSettingsManager
                    HandleShortcuts.executeInternalFunction("__settings")
                }
            }
        }

        Connections {
            target: loader
            onSettingsManagerPassOn: {
                if(what == "show") {
                    resetSettings()
                    opacity = 1
                    if(variables.visibleItem == "filedialog")
                        variables.settingsManagerOnTopOfFileDialog = true
                    variables.visibleItem = "settingsmanager"
                    isScrollBarVisible()
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
                    else if(param[0] == Qt.Key_1 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
                        bar.currentIndex = 0
                    else if(param[0] == Qt.Key_2 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
                        bar.currentIndex = 1
                    else if(param[0] == Qt.Key_3 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
                        bar.currentIndex = 2
                    else if(param[0] == Qt.Key_4 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
                        bar.currentIndex = 3
                    else if(param[0] == Qt.Key_5 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
                        bar.currentIndex = 4
                    else if(param[0] == Qt.Key_6 && ((param[1] & Qt.AltModifier) || (param[1] & Qt.ControlModifier)))
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
